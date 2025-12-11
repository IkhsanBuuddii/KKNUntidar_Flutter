FROM node:18-alpine
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --silent || npm i --omit=dev --silent

COPY . .

RUN npx prisma generate
RUN npm run build

EXPOSE 3001
CMD ["npm", "start"]
