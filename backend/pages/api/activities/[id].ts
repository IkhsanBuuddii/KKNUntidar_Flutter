import type { NextApiRequest, NextApiResponse } from 'next'
import prisma from '../../../lib/prismaClient'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query
  const activityId = Number(id)
  if (Number.isNaN(activityId)) return res.status(400).json({ error: 'invalid id' })

  if (req.method === 'GET') {
    const item = await prisma.activity.findUnique({ where: { id: activityId }, include: { user: true } })
    if (!item) return res.status(404).json({ error: 'not found' })
    return res.status(200).json(item)
  }

  if (req.method === 'PUT') {
    const { title, description } = req.body
    const updated = await prisma.activity.update({ where: { id: activityId }, data: { title, description } })
    return res.status(200).json(updated)
  }

  if (req.method === 'DELETE') {
    await prisma.activity.delete({ where: { id: activityId } })
    return res.status(204).end()
  }

  res.setHeader('Allow', ['GET', 'PUT', 'DELETE'])
  return res.status(405).end(`Method ${req.method} Not Allowed`)
}
