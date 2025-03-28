FROM node:18-slim

WORKDIR /app

COPY scripts/package.json scripts/package-lock.json ./

# Install dependencies
RUN npm install --omit=dev --no-package-lock

COPY scripts/upload_pinata.js ./upload_pinata.js
COPY ./unigecard ./unigecard

CMD ["node", "upload_pinata.js"]