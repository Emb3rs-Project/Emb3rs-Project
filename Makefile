MS_GRPC_PLIBS_PATH := ../platform/ms-grpc/plibs

install-client:
	@echo '--> Initializing client requirements'
	@if ! python3 -m venv --help; then \
	  apt install -y python3-venv; \
	fi
	@if ! pip --version; then \
	  apt install -y python3-pip; \
	fi
	@python3 -m venv client/venv
	@. client/venv/bin/activate && \
	pip install -r client/requirements.txt

request-client:
	@echo '--> Running client gRPC request to Manager Simulation'
	@. client/venv/bin/activate && \
	cd client && \
	PYTHONPATH=$PYTHONPATH:${MS_GRPC_PLIBS_PATH} ${args} python3 server.py

DEV_DOCKER_ENV_FILE := docker/dev/.env.dev
DEV_DOCKER_COMPOSE_FILE := docker/dev/docker-compose.yml
DEV_DOCKER_BASE_CMD := docker-compose -f ${DEV_DOCKER_COMPOSE_FILE} --env-file ${DEV_DOCKER_ENV_FILE}

install-dev:
	@echo '--> Initializing DEV requirements'
	@sed -i 's+git@github.com:+https://github.com/+g' .gitmodules
	@git submodule update --init --recursive
	@cp docker/dev/.env.dev platform/.env
	# TODO: Improve submodule initialize

docker-dev:
	@echo '--> Running custom command in DEV docker'
	@${DEV_DOCKER_BASE_CMD} ${cmd}

docker-dev-build:
	@echo '--> Did you paste Laravel Nova licensed folder within path /platform/.? (y/n)'
	@read user_response; \
	if echo $$user_response | grep -iq '^n'; then \
		echo '--> Please ask one of your teammates to help you with this.'; \
		exit 1; \
	fi

	@echo "--> Verifying with .env file exists within platform"
	@find . -name ".env" | cp docker/dev/.env.dev platform/.env

	@echo '--> Building the DEV docker'
	@${DEV_DOCKER_BASE_CMD} up --build -d

	@echo '--> Updating Platform Composer in DEV docker (REMOVE AFTER CHANGE REPOSITORIES PROPERTY IN COMPOSER.JSON OF PLATFORM REPOSITORY)'
	@${DEV_DOCKER_BASE_CMD} exec platform composer update

#	 @echo '--> Installing Platform Composer dependencies in DEV docker (UNCOMMENT AFTER CHANGE COMPOSER.JSON OF PLATFORM REPOSITORY)'
#	 @${DEV_DOCKER_BASE_CMD} exec platform composer install --optimize-autoloader --no-dev

	@echo '--> Adding permission to read Platform Laravel logs in DEV docker'
	@${DEV_DOCKER_BASE_CMD} exec platform chmod -R 777 /var/www/storage

	@echo '--> Building Platform Yarn in DEV docker'
	@${DEV_DOCKER_BASE_CMD} exec platform yarn
	@${DEV_DOCKER_BASE_CMD} exec platform yarn prod

	@echo '--> Running Platform Artisan commands in DEV docker'
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan cache:clear
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan route:cache
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan migrate --force
	@${DEV_DOCKER_BASE_CMD} exec platform php artisan db:seed --force

	@echo '--> Adding SSL Certificates to expose Platform with HTTPS in DEV docker'
	@${DEV_DOCKER_BASE_CMD} exec platform openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
	@${DEV_DOCKER_BASE_CMD} exec platform openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

	@echo '--> Applying NGINX configurations in DEV docker'
	@${DEV_DOCKER_BASE_CMD} exec platform service nginx start
	@${DEV_DOCKER_BASE_CMD} exec platform /etc/init.d/php8.1-fpm start

	@echo '--> Built with success! Run: make docker-dev-up'
	@@${DEV_DOCKER_BASE_CMD} stop

docker-dev-up:
	@echo '--> Running the DEV docker'
	@${DEV_DOCKER_BASE_CMD} up -d

docker-dev-stop:
	@echo '--> Stopping the DEV docker'
	@${DEV_DOCKER_BASE_CMD} stop

docker-dev-down:
	@echo '--> Removing the DEV docker'
	@${DEV_DOCKER_BASE_CMD} down
	@echo '--> Removing folders in platform created by build'
	@rm -rf platform/vendor platform/node_modules

docker-dev-logs:
	@echo '--> Logging the DEV docker for service(s) ${args}'
	@${DEV_DOCKER_BASE_CMD} logs ${args}

QA_DOCKER_ENV_FILE := docker/qa/.env.qa
QA_DOCKER_COMPOSE_FILE := docker/qa/docker-compose.yml
QA_DOCKER_BASE_CMD := docker-compose -f ${QA_DOCKER_COMPOSE_FILE} --env-file ${QA_DOCKER_ENV_FILE}

install-qa:
	@echo '--> Initializing QA requirements'
	@sed -i 's+git@github.com:+https://github.com/+g' .gitmodules
	@git submodule update --init --recursive
	@cp docker/qa/.env.qa platform/.env

docker-qa:
	@echo '--> Running custom command in QA docker'
	@${QA_DOCKER_BASE_CMD} ${cmd}

docker-qa-build:
	@echo '--> Did you paste Laravel Nova licensed folder within path /platform/.? (y/n)'
	@read user_response; \
	if echo $$user_response | grep -iq '^n'; then \
		echo '--> Please ask one of your teammates to help you with this.'; \
		exit 1; \
	fi

	@echo "--> Verifying with .env file exists within platform"
	@find . -name ".env" | cp docker/qa/.env.qa platform/.env

	@echo '--> Building the QA docker'
	@${QA_DOCKER_BASE_CMD} up --build -d

	@echo '--> Updating Platform Composer in QA docker (REMOVE AFTER CHANGE REPOSITORIES PROPERTY IN COMPOSER.JSON OF PLATFORM REPOSITORY)'
	@${QA_DOCKER_BASE_CMD} exec platform composer update

#	 @echo '--> Installing Platform Composer dependencies in QA docker (UNCOMMENT AFTER CHANGE COMPOSER.JSON OF PLATFORM REPOSITORY)'
#	 @${QA_DOCKER_BASE_CMD} exec platform composer install --optimize-autoloader --no-dev

	@echo '--> Adding permission to read Platform Laravel logs in QA docker'
	@${QA_DOCKER_BASE_CMD} exec platform chmod -R 777 /var/www/storage

	@echo '--> Building Platform Yarn in QA docker'
	@${QA_DOCKER_BASE_CMD} exec platform yarn
	@${QA_DOCKER_BASE_CMD} exec platform yarn prod

	@echo '--> Running Platform Artisan commands in QA docker'
	@${QA_DOCKER_BASE_CMD} exec platform php artisan cache:clear
	@${QA_DOCKER_BASE_CMD} exec platform php artisan route:cache
	@${QA_DOCKER_BASE_CMD} exec platform php artisan migrate --force
	@${QA_DOCKER_BASE_CMD} exec platform php artisan db:seed --force

	@echo '--> Adding SSL Certificates to expose Platform with HTTPS in QA docker'
	@${QA_DOCKER_BASE_CMD} exec platform openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
	@${QA_DOCKER_BASE_CMD} exec platform openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

	@echo '--> Applying NGINX configurations in QA docker'
	@${QA_DOCKER_BASE_CMD} exec platform service nginx start
	@${QA_DOCKER_BASE_CMD} exec platform /etc/init.d/php8.1-fpm start

	@echo '--> Built with success! Run: make docker-qa-up'
	@${QA_DOCKER_BASE_CMD} stop

docker-qa-up:
	@echo '--> Running the QA docker'
	@${QA_DOCKER_BASE_CMD} up -d

docker-qa-stop:
	@echo '--> Stopping the QA docker'
	@${QA_DOCKER_BASE_CMD} stop

docker-qa-down:
	@echo '--> Removing the QA docker'
	@${QA_DOCKER_BASE_CMD} down
	@echo '--> Removing folders in platform created by build'
	@rm -rf platform/vendor platform/node_modules

docker-qa-logs:
	@echo '--> Logging the QA docker for service(s) ${args}'
	@${QA_DOCKER_BASE_CMD} logs ${args}
