FROM node:16 as builder

WORKDIR /usr/src/app
COPY . .

ENV NODE_ENV=/ 
ENV VUE_APP_API_URL=/
RUN npm install -cache .npm --prefer-offline && \
    npm run build


FROM nginx:latest
WORKDIR /app
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html
EXPOSE 80
