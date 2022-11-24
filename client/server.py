import json
import os
from datetime import datetime

import grpc
import jsonpickle
from manager.manager_pb2_grpc import ManagerStub
from manager.manager_pb2 import StartSimulationRequest
from manager.manager_models import StartSimulationResponseModel

MANAGER_GRPC_HOST = os.getenv("MANAGER_GRPC_HOST", "127.0.0.1")
MANAGER_GRPC_PORT = os.getenv("MANAGER_GRPC_PORT", "50041")
SIMULATION_DATA_PATH = os.getenv("SIMULATION_DATA_PATH", "simulation_data.json")

print(f"--> Configuring gRPC Manager Stub to {MANAGER_GRPC_HOST}:{MANAGER_GRPC_PORT}")
manager_channel = grpc.insecure_channel(target=f"{MANAGER_GRPC_HOST}:{MANAGER_GRPC_PORT}")
manager = ManagerStub(channel=manager_channel)

print(f"--> Reading data from {SIMULATION_DATA_PATH}")
with open(SIMULATION_DATA_PATH) as file:
    simulation_data = json.loads(file.read())

print("--> Preparing Simulation request")
request = StartSimulationRequest(
    simulation_uuid=simulation_data["simulationUuid"],
    simulation_metadata=jsonpickle.encode(simulation_data["simulationMetadata"]),
    initial_data=jsonpickle.encode(simulation_data["initialData"]),
)

start = datetime.now()
print(f"--> [{start}] Requesting StartSimulation")
response = manager.StartSimulation(request)
end = datetime.now()
print(f"--> [{end}] Finishing StartSimulation")

print("--> Reading response from StartSimulation")
output = StartSimulationResponseModel().from_grpc(response)
print(f"--> Data: {output.dict()}")

result = end - start
print(f"--> Finishing process with time: {result}")
