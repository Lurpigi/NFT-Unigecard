FROM node:18-slim

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY upload_pinata.js ./upload_pinata.js

ARG DATA
COPY $DATA ./$DATA

CMD ["node", "upload_pinata.js"]
