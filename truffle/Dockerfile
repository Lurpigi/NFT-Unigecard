FROM node:18-slim

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY contracts ./contracts
COPY migrations ./migrations
COPY truffle-config.js ./

CMD [ "sh", "-c", "npx truffle compile && npx truffle migrate --network sepolia" ]
#CMD [ "sh", "-c", "npx truffle compile && npx truffle migrate --network sepolia --dry-run" ] #estimate gas cost