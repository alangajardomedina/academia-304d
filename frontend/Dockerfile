#Multistage
# Stage 1
FROM node:20-alpine AS builder
WORKDIR /build
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2
FROM nginx:alpine
COPY --from=builder /build/dist /usr/share/nginx/html
EXPOSE 80
