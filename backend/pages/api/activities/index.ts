import type { NextApiRequest, NextApiResponse } from 'next'
import prisma from '../../../lib/prismaClient'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    const activities = await prisma.activity.findMany({ include: { user: true } })
    return res.status(200).json(activities)
  }

  if (req.method === 'POST') {
    const { title, description, userId } = req.body
    if (!title || !userId) return res.status(400).json({ error: 'title and userId required' })
    const activity = await prisma.activity.create({ data: { title, description, userId: Number(userId) } })
    return res.status(201).json(activity)
  }

  res.setHeader('Allow', ['GET', 'POST'])
  return res.status(405).end(`Method ${req.method} Not Allowed`)
}
