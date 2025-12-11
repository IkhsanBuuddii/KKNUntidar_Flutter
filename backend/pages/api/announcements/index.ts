import type { NextApiRequest, NextApiResponse } from 'next'
import prisma from '../../../lib/prismaClient'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    const announcements = await prisma.announcement.findMany()
    return res.status(200).json(announcements)
  }

  if (req.method === 'POST') {
    const { title, content } = req.body
    if (!title || !content) return res.status(400).json({ error: 'title and content required' })
    const a = await prisma.announcement.create({ data: { title, content } })
    return res.status(201).json(a)
  }

  res.setHeader('Allow', ['GET', 'POST'])
  return res.status(405).end(`Method ${req.method} Not Allowed`)
}
