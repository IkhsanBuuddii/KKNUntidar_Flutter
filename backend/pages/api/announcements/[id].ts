import type { NextApiRequest, NextApiResponse } from 'next'
import prisma from '../../../lib/prismaClient'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query
  const itemId = Number(id)
  if (Number.isNaN(itemId)) return res.status(400).json({ error: 'invalid id' })

  if (req.method === 'GET') {
    const item = await prisma.announcement.findUnique({ where: { id: itemId } })
    if (!item) return res.status(404).json({ error: 'not found' })
    return res.status(200).json(item)
  }

  if (req.method === 'PUT') {
    const { title, content } = req.body
    const updated = await prisma.announcement.update({ where: { id: itemId }, data: { title, content } })
    return res.status(200).json(updated)
  }

  if (req.method === 'DELETE') {
    await prisma.announcement.delete({ where: { id: itemId } })
    return res.status(204).end()
  }

  res.setHeader('Allow', ['GET', 'PUT', 'DELETE'])
  return res.status(405).end(`Method ${req.method} Not Allowed`)
}
