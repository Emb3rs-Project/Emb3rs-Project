
![](EMB3Rs-Logo.jpg?raw=true)


# Structure of Repositories

ModuleSystem/---
- ms-manager
- ms-reporter
- ms-wrapper
- ms-core
- ms-mapper-service
- ms-network

Platform
- web

Module/---
- m-core-functionalities
- m-gis
- m-market
- m-business
- m-teo

Prototypes/---
- p-core-functionalities
- p-gis
- p-market
- p-business
- p-teo  

# Setup Development Environment
Below have instructions about how setup project for development environment.

**NOTE:** *Commands that run docker maybe needs `sudo` permission, if necessary use `sudo` before each command, .e.g: `sudo make ...`*  

### Initial Step
To start configuration, run:
```shell
make install
```

## Building and running Docker Compose
Build containers running:
```shell
make docker-dev-build
```

The script will ask if did you paste the Laravel Nova path in platform, then answer with y or n.

After build, run command to up containers:
```shell
make docker-dev-up
```

**Check if the app is running ok:** http://localhost:80

## Docker Compose Commands with Makefile
Build containers running:
```shell
make docker-dev-build
```

Start containers running:
```shell
make docker-dev-up
```

Stop containers running:
```shell
make docker-dev-stop
```

Down containers running:
```shell
make docker-dev-down
```

If you need see logs, could run:
```shell
make docker-dev-logs
```

For a specific logs, run:
```shell
make docker-dev-logs args='platform pgsql'
```

For custom commands to docker compose, run:
```shell
make docker-dev cmd='exec platform bash'
# or make docker-dev cmd='exec platform php artisan..'
```
