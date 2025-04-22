FROM node:18-slim

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY contracts ./contracts
COPY migrations ./migrations
COPY truffle-config.js ./

#CMD ["npx", "truffle", "compile"]
CMD [ "sh", "-c", "npx truffle compile && echo 'ciao'" ]
