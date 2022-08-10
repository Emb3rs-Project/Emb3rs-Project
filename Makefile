DEV_DOCKER_ENV_FILE := docker/dev/.env.dev
DEV_DOCKER_COMPOSE_FILE := docker/dev/docker-compose.yml
DEV_DOCKER_BASE_CMD := docker-compose -f ${DEV_DOCKER_COMPOSE_FILE} --env-file ${DEV_DOCKER_ENV_FILE}

install:
	@git submodule init
	@git submodule update
	@cp docker/dev/.env.dev platform/.env
	@cd platform && git submodule init
	@cd platform && git submodule update

docker-dev:
	@echo '--> Running custom command in development docker'
	@${DEV_DOCKER_BASE_CMD} ${cmd}

docker-dev-build: install
	@echo '--> Did you paste Laravel Nova licensed folder within path /platform/.? (y/n)'
	@read user_response; \
	if echo $$user_response | grep -iq '^n'; then \
		echo '--> Please ask one of your teammates to help you with this.'; \
		exit 1; \
	fi

	@echo "--> Verifying with .env file exists within platform"
	@find . -name ".env" | cp docker/dev/.env.dev platform/.env

	@echo '--> Building the development docker'
	@${DEV_DOCKER_BASE_CMD} up --build -d

	@echo '--> Updating Platform Composer in development docker (REMOVE AFTER CHANGE REPOSITORIES PROPERTY IN COMPOSER.JSON OF PLATFORM REPOSITORY)'
	@${DEV_DOCKER_BASE_CMD} exec platform composer update

	# @echo '--> Instaling Platform Composer dependencies in development docker' (UNCOMMENT AFTER CHANGE COMPOSER.JSON OF PLATFORM REPOSITORY)
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
	@${DEV_DOCKER_BASE_CMD} up

docker-dev-stop:
	@echo '--> Stopping the development docker'
	@${DEV_DOCKER_BASE_CMD} stop

docker-dev-down:
	@echo '--> Removing the development docker'
	@${DEV_DOCKER_BASE_CMD} down
	@echo '--> Removing folders in platform created by build'
	@rm -rf platform/vendor platform/node_modules

docker-dev-logs:
	@echo '--> Logging the development docker for service(s) ${args}'
	@${DEV_DOCKER_BASE_CMD} logs ${args}