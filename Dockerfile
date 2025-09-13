#stage 1


FROM node:18-alpine AS development
RUN apk add --no-cache python3 make g++
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build


#stage 2
FROM node:18-alpine AS production
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
RUN addgroup -g 1001 -S cgonzalez
RUN adduser -S cgonzalez -u 1001
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=development /usr/src/app/dist ./dist
RUN chown -R cgonzalez:cgonzalez /usr/src/app
USER cgonzalez
EXPOSE 3000
CMD ["node", "dist/main"]