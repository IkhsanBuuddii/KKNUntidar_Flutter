import type { NextApiRequest, NextApiResponse } from 'next'
import prisma from '../../../lib/prismaClient'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query
  const userId = Number(id)
  if (Number.isNaN(userId)) return res.status(400).json({ error: 'invalid id' })

  if (req.method === 'GET') {
    const user = await prisma.user.findUnique({ where: { id: userId }, include: { activities: true } })
    if (!user) return res.status(404).json({ error: 'not found' })
    return res.status(200).json(user)
  }

  if (req.method === 'PUT') {
    const { name, email } = req.body
    const updated = await prisma.user.update({ where: { id: userId }, data: { name, email } })
    return res.status(200).json(updated)
  }

  if (req.method === 'DELETE') {
    await prisma.user.delete({ where: { id: userId } })
    return res.status(204).end()
  }

  res.setHeader('Allow', ['GET', 'PUT', 'DELETE'])
  return res.status(405).end(`Method ${req.method} Not Allowed`)
}
