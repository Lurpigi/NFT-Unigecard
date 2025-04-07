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
    cd infUnigeNFT
    npm run dev