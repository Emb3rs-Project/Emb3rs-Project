![](EMB3Rs-Logo.jpg?raw=true)

Repository if infrastructure configuration to setup platform locally or in your own server.

# Ecosystem explanation
Emb3rs Modules and Platform works with different responsibilities looking to achieve one specific goal, using the input data for match heat and cold to reuse it.

The ecosystem is consisted on *Module Systems*, *Module Integrations* and *Web Platform*.

* **Module Systems** has the responsibility to receive, process and return  data about feasibility or infeasability of Heat and Cold Matching. Are identified in repositories starting with prefix **p-** on name.
* **Module Integrations** has the responsibility to handle requests from *Web Platform* and translate this to call *Module Systems*. Are identified in repositories starting with prefix **ms-** on name.
* **Web Platform*** has the resposibility to be a interface to the client that wants to find Heat and Cold Matching with a set of data. Is the repository named as **platform**.

# Installation Requirements
**NOTE:** *We don't have a script to install it without docker, if you can and want, contribute on this repository with a script to setup in a different way, we will really appreciate it.*

To run Emb3rs Ecosystem, we use mainly Docker and Docker Compose. Each module has your own docker image with the versions *latest*, *master*, *qa* and *dev*.

Minimum requirements:
* Linux Server or similar Unix
* Git
* Docker
* Docker Compose
* GNU Make
* Laravel Nova license
* COPT or GUROBI license, if you want to use one of these else we offer free solutions like HiGHS and SCIP as well

# Setting Up
We have three possibilities of setup: **dev**, **qa** and **prod**. Each command described below must use the same affix (dev or qa or prod) when setting up, for example:
- For **dev** environment: `make install-dev`, `make docker-dev` and etc
- For **qa** environment `make install-qa`, `make docker-qa` and etc
- For **prod** environment `make install-prod`, `make docker-prod` and etc

Below we explain how to setup the whole Emb3rs Ecosystem using Docker and GNU Make.

**NOTES:**
- *Commands that run docker maybe needs `sudo` permission, if necessary use `sudo` before each command, .e.g: `sudo docker`, `sudo make`, etc..*
- *Change {env} in below commands to desired environement (dev, qa or prod)*

To initialize the submodules and create environment variables file, run:
```shell
make install-{env}
```

To build platform and module integrations containers, run:
```shell
make docker-{env}-build
```

The script will ask if you have pasted the Laravel Nova licensed path in platform directory, after do it answer with `y` or `n`.

After build, run the command to setup the containers:
```shell
make docker-{env}-up
```

**In local environment check if the app is running ok:** http://localhost:80

# Available Commands in Makefile
**NOTE**: *If you'll run QA environment, comment lines 74 and 75 in platform/Dockerfile.*

The commands below should be executed using `make` before action, e.g. `make install-dev`.

|              Command               |                                                  Description                                                |  Environments  |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------- | -------------- |
| install-{env}                      | Initiliaze mininum requirements                                                                             | dev, qa, prod  |
| docker-{env} cmd='arguments'       | Run a custom command in passing argument in cmd, e.g. `... cmd='exec m_gis bash'`                           | dev, qa, prod  |
| docker-{env}-build                 | Build all docker containers necessary to run whole ecosystem                                                | dev, qa, prod  |
| docker-{env}-up                    | Start all docker containers in background                                                                   | dev, qa, prod  |
| docker-{env}-stop                  | Stop all docker containers setted up                                                                        | dev, qa, prod  |
| docker-{env}-down                  | Remove all docer containers created                                                                         | dev, qa, prod  |
| docker-{env}-logs                  | Show logs from each docker container running                                                                | dev, qa, prod  |
| docker-{env}-logs args='arguments' | Show logs from each docker container running in arguments conditions, e.g. `... args='--tail=200 -f m_gis'` | dev, qa, prod  |
| install-client                     | Install the client requirements to run simulation from script                                               | dev, qa, prod  |
| request-client                     | Request to the Manager service using data defined in client directory                                       | dev, qa, prod  |

### Some examples of arguments
For logs of a specific container:
```shell
make docker-dev-logs args='platform pgsql'
```

For a specific line of logs of a specific container:
```shell
make docker-dev-logs args='--tail=500 pgsql'
```

For logs of a specific container following new logs:
```shell
make docker-dev-logs args='-f pgsql'
```

For custom commands to docker compose:
```shell
make docker-dev cmd='exec platform bash'
# or make docker-dev cmd='exec platform php artisan..'
```

# Requesting Manager Simulation with gRPC Client
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