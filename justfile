set dotenv-load

switch-branch branch:
    git checkout {{branch}}

upload:
    docker compose build --no-cache upload-pinata
    docker compose up upload-pinata

test-upload:
    docker compose build --no-cache upload-pinata-test
    docker compose up upload-pinata-test

stop:
    docker compose stop

down:
    docker compose down --remove-orphans
    docker volume prune -f
    docker network prune -f
    docker system prune -f
    docker builder prune -f
    docker image prune -f
    docker container prune -f

run-frontend:
    docker compose build --no-cache frontend
    docker compose up frontend

deploy-contract:
    docker compose build --no-cache deploy-contract
    docker compose up deploy-contract

build-frontend:
    #docker compose up --build -d build-frontend
    #docker cp $(docker compose ps -q build-frontend):/app/.output ./infUnigeNFT/
    npm install
    rm -rf dist
    cd infUnigeNFT
    rm -rf .output
    npm install && npm run generate && cd ..
    cp -r infUnigeNFT/.output/public dist
    npx gh-pages -d dist

