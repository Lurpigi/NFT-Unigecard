FROM node:18-slim

WORKDIR /app

COPY package.json package-lock.json ./

# Install dependencies
RUN npm install --omit=dev --no-package-lock

COPY upload_pinata.js ./upload_pinata.js
COPY ../unigecard ./unigecard

CMD ["node", "upload_pinata.js"]