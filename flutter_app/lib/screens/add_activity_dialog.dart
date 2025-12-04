import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/prefs_service.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';

class AddActivityDialog extends StatefulWidget {
  const AddActivityDialog({super.key});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _location = TextEditingController();
  XFile? _pickedImage;
  Uint8List? _pickedImageData;
  bool _saving = false;

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final file = await p.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
    if (file != null) {
      if (!mounted) return;
      setState(() => _pickedImage = file);
    }
  }

  Future<void> _pickGalleryImage() async {
    final p = ImagePicker();
    final file = await p.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedImage = file;
        _pickedImageData = bytes;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) _dateCtrl.text = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) _timeCtrl.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<String?> _savePickedFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (kIsWeb) {
        // store as data URL for web
        return 'data:image/jpeg;base64,' + base64Encode(bytes);
      }
      final dir = await getApplicationDocumentsDirectory();
      final id = const Uuid().v4();
      final out = File('${dir.path}/activity_$id.jpg');
      await out.writeAsBytes(bytes);
      return out.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final desc = _description.text.trim();
    final date = _dateCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final location = _location.text.trim();
    if (title.isEmpty || date.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon isi judul, tanggal, dan waktu')));
      return;
    }
    if (!mounted) return;
    setState(() => _saving = true);
    String? photoPath;
    if (_pickedImage != null) {
      final p = await _savePickedFile(_pickedImage!);
      if (p != null) photoPath = p;
    }

    final activity = ActivityModel(title: title, description: desc, date: date, time: time, location: location, userEmail: await _guessUserEmail(), photoPath: photoPath);
    await DatabaseHelper.instance.addActivity(activity);

    // optional server sync (placeholder): won't fail migration if server has no endpoint
    try {
      await ApiService.addActivity(activity.toMap());
    } catch (_) {}

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    }
  }

  Future<String> _guessUserEmail() async {
    // try to get from prefs; if not available use empty string
    try {
      final e = await PrefsService.getUserEmail();
      return e ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(12),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Tambah Kegiatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(hintText: 'Judul Kegiatan')),
          const SizedBox(height: 8),
          TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(hintText: 'Deskripsi Kegiatan')),
          const SizedBox(height: 8),
          TextField(controller: _dateCtrl, readOnly: true, onTap: _pickDate, decoration: const InputDecoration(hintText: 'Tanggal (DD/MM/YYYY)')),
          const SizedBox(height: 8),
          TextField(controller: _timeCtrl, readOnly: true, onTap: _pickTime, decoration: const InputDecoration(hintText: 'Waktu (HH:MM)')),
          const SizedBox(height: 8),
          TextField(controller: _location, decoration: const InputDecoration(hintText: 'Lokasi')),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt), label: const Text('Kamera')),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: _pickGalleryImage, icon: const Icon(Icons.photo_library), label: const Text('Galeri')),
          ]),
          const SizedBox(height: 8),
          if (_pickedImage != null)
            if (kIsWeb && _pickedImageData != null)
              Image.memory(_pickedImageData!, width: 120, height: 120, fit: BoxFit.cover)
            else
              Image.file(File(_pickedImage!.path), width: 120, height: 120, fit: BoxFit.cover),
        ]),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(false), child: const Text('Batal')),
        ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('Simpan')),
      ],
    );
  }
}
