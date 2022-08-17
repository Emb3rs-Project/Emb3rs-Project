
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
**NOTE**: *If you want to run QA environment, change dev to qa (e.g: make install-qa, make docker-qa-build, make docker-qa-up)*  

Initializing requirements:
```shell
make install-dev
```

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

## Requesting Manager Simulation with gRPC Client
Initialize requirements:
```shell
make install-client
```

Request with client (*by default will call 127.0.0.1:50041 with client/simulation_data.json*):
```shell
make request-client
```

To custom request (another host, port or file data):
```shell
make request-client args='MANAGER_GRPC_HOST=0.0.0.0 MANAGER_GRPC_PORT=50001'
```

Possible parameters (all optional):
- MANAGER_GRPC_HOST (e.g: MANAGER_GRPC_HOST=localhost)
- MANAGER_GRPC_PORT (e.g: MANAGER_GRPC_PORT=80001)
- SIMULATION_DATA_PATH (e.g: SIMULATION_DATA_PATH=~/project/simulation_custom.json)

If you want to run without Makefile, run:
```shell
cd client
python -m venv venv  # create virtual env
source venv/bin/activate  # activate virtual env
pip install -r requirements.txt  # install requirements
PYTHONPATH=$PYTHONPATH:ms_grpc/plibs python server.py  # run client
```