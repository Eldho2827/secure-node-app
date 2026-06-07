# Stage 1 - Build Stage

FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Stage 2 - Production Stage

FROM node:18-alpine

WORKDIR /app

COPY --from=builder /app .

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

CMD ["node", "app.js"]
