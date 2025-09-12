# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
# No build step needed for this app

# Runtime stage
FROM node:18-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodeapp -u 1001
COPY --from=builder --chown=nodeapp:nodejs /app .
USER nodeapp
EXPOSE 3000
CMD ["npm", "start"]