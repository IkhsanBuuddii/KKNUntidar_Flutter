import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/activity.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _db;
  static const _dbName = 'KKNTrack.db';
  static const _dbVersion = 2;

  Future<Database> get db async {
    if (kIsWeb) {
      // On web we don't use sqflite. Caller should use the web-specific
      // fallback methods implemented per-method below.
      throw UnsupportedError('Database not available on web');
    }
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT,
        nim TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT,
        time TEXT,
        location TEXT,
        user_email TEXT,
        photo_path TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE activities ADD COLUMN photo_path TEXT');
    }
  }

  // Password hashing: PBKDF2-HMAC-SHA256
  static const int _iterations = 10000;
  static const int _keyLength = 32; // bytes

  String _generateSalt([int length = 16]) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return hex.encode(bytes);
  }

  List<int> _pbkdf2(List<int> password, List<int> salt, int iterations, int dkLen) {
    // Implements PBKDF2 with HMAC-SHA256
    final hLen = sha256.convert([]).bytes.length;
    final l = (dkLen / hLen).ceil();
    final out = <int>[];

    for (var i = 1; i <= l; i++) {
      // U1 = PRF(password, salt || INT(i))
      final block = <int>[]..addAll(salt)..addAll(_int32be(i));
      var u = Hmac(sha256, password).convert(block).bytes;
      var t = List<int>.from(u);
      for (var j = 1; j < iterations; j++) {
        u = Hmac(sha256, password).convert(u).bytes;
        for (var k = 0; k < t.length; k++) t[k] ^= u[k];
      }
      out.addAll(t);
    }
    return out.sublist(0, dkLen);
  }

  List<int> _int32be(int i) => [ (i >> 24) & 0xFF, (i >> 16) & 0xFF, (i >> 8) & 0xFF, i & 0xFF ];

  String _hashPassword(String password) {
    final saltHex = _generateSalt();
    final salt = hex.decode(saltHex);
    final dk = _pbkdf2(password.codeUnits, salt, _iterations, _keyLength);
    final dkHex = hex.encode(dk);
    return '\$pbkdf2-sha256\$$_iterations\$${saltHex}\$${dkHex}';
  }

  bool _verifyPassword(String password, String stored) {
    try {
      if (!stored.startsWith('\$pbkdf2-sha256\$')) {
        // legacy plain
        return stored == password;
      }
      final parts = stored.split('\$');
      // ['', 'pbkdf2-sha256', 'iterations', 'salt', 'dk']
      if (parts.length < 5) return false;
      final iterations = int.parse(parts[2]);
      final salt = hex.decode(parts[3]);
      final dkStored = hex.decode(parts[4]);
      final dk = _pbkdf2(password.codeUnits, salt, iterations, dkStored.length);
      if (dk.length != dkStored.length) return false;
      var diff = 0;
      for (var i = 0; i < dk.length; i++) diff |= dk[i] ^ dkStored[i];
      return diff == 0;
    } catch (e) {
      if (kDebugMode) print('verify error: $e');
      return false;
    }
  }

  // User methods
  Future<int> addUser(User user) async {
    if (kIsWeb) return await _webAddUser(user);
    final database = await db;
    final hashed = _hashPassword(user.password);
    final map = {
      'full_name': user.fullName,
      'nim': user.nim,
      'email': user.email,
      'phone': user.phone,
      'password': hashed,
    };
    return await database.insert('users', map);
  }

  Future<bool> checkUser(String email, String password) async {
    if (kIsWeb) return await _webCheckUser(email, password);
    final database = await db;
    final res = await database.query('users', columns: ['password'], where: 'email = ?', whereArgs: [email]);
    if (res.isEmpty) return false;
    final stored = res.first['password'] as String?;
    if (stored == null) return false;
    return _verifyPassword(password, stored);
  }

  Future<bool> checkUserExists(String email) async {
    if (kIsWeb) return await _webCheckUserExists(email);
    final database = await db;
    final res = await database.query('users', columns: ['id'], where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty;
  }

  Future<User?> getUserByEmail(String email) async {
    if (kIsWeb) return await _webGetUserByEmail(email);
    final database = await db;
    final res = await database.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
  }

  Future<bool> updateUser(User user) async {
    if (kIsWeb) return await _webUpdateUser(user);
    final database = await db;
    final map = {
      'full_name': user.fullName,
      'nim': user.nim,
      'phone': user.phone,
    };
    final res = await database.update('users', map, where: 'email = ?', whereArgs: [user.email]);
    return res > 0;
  }

  Future<bool> updateUserPassword(String email, String newPassword) async {
    if (kIsWeb) return await _webUpdateUserPassword(email, newPassword);
    final database = await db;
    final hashed = _hashPassword(newPassword);
    final res = await database.update('users', {'password': hashed}, where: 'email = ?', whereArgs: [email]);
    return res > 0;
  }

  // Activities methods (examples)
  Future<int> addActivity(ActivityModel activity) async {
    if (kIsWeb) return await _webAddActivity(activity);
    final database = await db;
    return await database.insert('activities', activity.toMap());
  }

  Future<bool> updateActivity(ActivityModel activity) async {
    if (kIsWeb) return await _webUpdateActivity(activity);
    final database = await db;
    final res = await database.update('activities', activity.toMap(), where: 'id = ?', whereArgs: [activity.id]);
    return res > 0;
  }

  Future<bool> deleteActivity(int activityId) async {
    if (kIsWeb) return await _webDeleteActivity(activityId);
    final database = await db;
    final res = await database.delete('activities', where: 'id = ?', whereArgs: [activityId]);
    return res > 0;
  }

  Future<ActivityModel?> getActivityById(int activityId) async {
    if (kIsWeb) return await _webGetActivityById(activityId);
    final database = await db;
    final res = await database.query('activities', where: 'id = ?', whereArgs: [activityId]);
    if (res.isEmpty) return null;
    return ActivityModel.fromMap(res.first);
  }

  Future<int> getActivitiesCountByUser(String userEmail) async {
    if (kIsWeb) return await _webGetActivitiesCountByUser(userEmail);
    final database = await db;
    final res = await database.rawQuery('SELECT COUNT(*) as c FROM activities WHERE user_email = ?', [userEmail]);
    if (res.isEmpty) return 0;
    return res.first['c'] as int? ?? 0;
  }

  Future<String?> getLastActivityByUser(String userEmail) async {
    if (kIsWeb) return await _webGetLastActivityByUser(userEmail);
    final database = await db;
    final res = await database.query('activities', columns: ['title'], where: 'user_email = ?', whereArgs: [userEmail], orderBy: 'date DESC, time DESC', limit: 1);
    if (res.isEmpty) return null;
    return res.first['title'] as String?;
  }

  Future<List<ActivityModel>> getActivitiesByUser(String userEmail) async {
    if (kIsWeb) return await _webGetActivitiesByUser(userEmail);
    final database = await db;
    final res = await database.query('activities', where: 'user_email = ?', whereArgs: [userEmail], orderBy: 'date DESC, time DESC');
    return res.map((m) => ActivityModel.fromMap(m)).toList();
  }

  // --- Web fallback implemented using SharedPreferences ---
  Future<List<Map<String, dynamic>>> _webLoadUsers() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('web_users') ?? '[]';
    final l = jsonDecode(s) as List<dynamic>;
    return l.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _webSaveUsers(List<Map<String, dynamic>> users) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('web_users', jsonEncode(users));
  }

  Future<int> _webAddUser(User user) async {
    final users = await _webLoadUsers();
    if (users.any((u) => u['email'] == user.email)) throw Exception('User exists');
    final hashed = _hashPassword(user.password);
    final id = (users.isEmpty ? 1 : (users.map((u) => u['id'] as int).reduce(max) + 1));
    final map = {
      'id': id,
      'full_name': user.fullName,
      'nim': user.nim,
      'email': user.email,
      'phone': user.phone,
      'password': hashed,
    };
    users.add(map);
    await _webSaveUsers(users);
    return id;
  }

  Future<bool> _webCheckUser(String email, String password) async {
    final users = await _webLoadUsers();
    final u = users.firstWhere((e) => e['email'] == email, orElse: () => <String, dynamic>{});
    if (u.isEmpty) return false;
    final stored = u['password'] as String?;
    if (stored == null) return false;
    return _verifyPassword(password, stored);
  }

  Future<bool> _webCheckUserExists(String email) async {
    final users = await _webLoadUsers();
    return users.any((u) => u['email'] == email);
  }

  Future<User?> _webGetUserByEmail(String email) async {
    final users = await _webLoadUsers();
    final u = users.firstWhere((e) => e['email'] == email, orElse: () => <String, dynamic>{});
    if (u.isEmpty) return null;
    return User.fromMap(u);
  }

  Future<bool> _webUpdateUser(User user) async {
    final users = await _webLoadUsers();
    final idx = users.indexWhere((u) => u['email'] == user.email);
    if (idx < 0) return false;
    users[idx]['full_name'] = user.fullName;
    users[idx]['nim'] = user.nim;
    users[idx]['phone'] = user.phone;
    await _webSaveUsers(users);
    return true;
  }

  Future<bool> _webUpdateUserPassword(String email, String newPassword) async {
    final users = await _webLoadUsers();
    final idx = users.indexWhere((u) => u['email'] == email);
    if (idx < 0) return false;
    users[idx]['password'] = _hashPassword(newPassword);
    await _webSaveUsers(users);
    return true;
  }

  Future<List<Map<String, dynamic>>> _webLoadActivities() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('web_activities') ?? '[]';
    final l = jsonDecode(s) as List<dynamic>;
    return l.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _webSaveActivities(List<Map<String, dynamic>> activities) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('web_activities', jsonEncode(activities));
  }

  Future<int> _webAddActivity(ActivityModel activity) async {
    final acts = await _webLoadActivities();
    final id = (acts.isEmpty ? 1 : (acts.map((a) => a['id'] as int).reduce(max) + 1));
    final map = activity.toMap();
    map['id'] = id;
    acts.add(map);
    await _webSaveActivities(acts);
    return id;
  }

  Future<bool> _webUpdateActivity(ActivityModel activity) async {
    final acts = await _webLoadActivities();
    final idx = acts.indexWhere((a) => a['id'] == activity.id);
    if (idx < 0) return false;
    acts[idx] = activity.toMap();
    await _webSaveActivities(acts);
    return true;
  }

  Future<bool> _webDeleteActivity(int activityId) async {
    final acts = await _webLoadActivities();
    final before = acts.length;
    acts.removeWhere((a) => a['id'] == activityId);
    await _webSaveActivities(acts);
    return acts.length < before;
  }

  Future<ActivityModel?> _webGetActivityById(int activityId) async {
    final acts = await _webLoadActivities();
    final a = acts.firstWhere((e) => e['id'] == activityId, orElse: () => <String, dynamic>{});
    if (a.isEmpty) return null;
    return ActivityModel.fromMap(a);
  }

  Future<int> _webGetActivitiesCountByUser(String userEmail) async {
    final acts = await _webLoadActivities();
    return acts.where((a) => a['user_email'] == userEmail).length;
  }

  Future<String?> _webGetLastActivityByUser(String userEmail) async {
    final acts = await _webLoadActivities();
    final userActs = acts.where((a) => a['user_email'] == userEmail).toList();
    if (userActs.isEmpty) return null;
    userActs.sort((a, b) {
      final da = '${a['date']} ${a['time']}';
      final db = '${b['date']} ${b['time']}';
      return db.compareTo(da);
    });
    return userActs.first['title'] as String?;
  }

  Future<List<ActivityModel>> _webGetActivitiesByUser(String userEmail) async {
    final acts = await _webLoadActivities();
    final userActs = acts.where((a) => a['user_email'] == userEmail).toList();
    userActs.sort((a, b) {
      final da = '${a['date']} ${a['time']}';
      final db = '${b['date']} ${b['time']}';
      return db.compareTo(da);
    });
    return userActs.map((m) => ActivityModel.fromMap(m)).toList();
  }
}
