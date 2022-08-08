DEV_DOCKER_ENV_FILE := docker/dev/.env.dev
DEV_DOCKER_COMPOSE_FILE := docker/dev/docker-compose.yml
DEV_DOCKER_BASE_CMD := docker-compose -f ${DEV_DOCKER_COMPOSE_FILE} --env-file ${DEV_DOCKER_ENV_FILE}

install:
	@git submodule init
	@git submodule update
	@cp docker/dev/.env.dev platform/.env

docker-dev:
	@echo '--> Running custom command in development docker'
	@${DEV_DOCKER_BASE_CMD} ${cmd}

docker-dev-build:
	@echo '--> Building the development docker'
	@${DEV_DOCKER_BASE_CMD} up --build -d

	@echo '--> Updating Platform Composer in development docker (REMOVE AFTER CHANGE REPOSITORIES OF PLATFORM)'
	@${DEV_DOCKER_BASE_CMD} exec platform composer update

	# @echo '--> Instaling Platform Composer dependencies in development docker'
	# @${DEV_DOCKER_BASE_CMD} exec platform composer install --optimize-autoloader --no-dev

	@echo '--> Adding permission to read Platform Laravel logs in development docker'
	@${DEV_DOCKER_BASE_CMD} exec platform chmod -R 777 /var/www/html/storage

	@echo '--> Building Platform Yarn in development docker'
	@${DEV_DOCKER_BASE_CMD} exec platform yarn
	@${DEV_DOCKER_BASE_CMD} exec platform yarn prod

	@echo '--> Running Platform Artisan commands in development docker'
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan cache:clear
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan route:cache
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan migrate --force
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan db:seed --force

	@echo '--> Builded with success! Run: make docker-dev-up'
	@@${DEV_DOCKER_BASE_CMD} stop

docker-dev-up:
	@echo '--> Running the development docker'
	@docker-compose -f ${DEV_DOCKER_COMPOSE_FILE} --env-file ${DEV_DOCKER_ENV_FILE} up

docker-dev-stop:
	@echo '--> Stopping the development docker'
	@docker-compose -f ${DEV_DOCKER_COMPOSE_FILE} --env-file ${DEV_DOCKER_ENV_FILE} stop

docker-dev-down:
	@echo '--> Removing the development docker'
	@docker-compose -f ${DEV_DOCKER_COMPOSE_FILE} --env-file ${DEV_DOCKER_ENV_FILE} down

docker-dev-logs:
	@echo '--> Logging the development docker for service(s) ${args}'
	@docker-compose -f ${DEV_DOCKER_COMPOSE_FILE} --env-file ${DEV_DOCKER_ENV_FILE} logs ${args}
