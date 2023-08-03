
#!/bin/bash

# Set variables
POD=${POD_NAME}
NAMESPACE=${POD_NAMESPACE}
K8S_MANIFEST=${K8S_MANIFEST_FILE}

# Get pod status
POD_STATUS=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{.status.phase}')

# Check if pod is running
if [ "$POD_STATUS" != "Running" ]
then
  echo "Pod is not running. Current status: $POD_STATUS"
  exit 1
fi

# Get pod restart count
POD_RESTARTS=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].restartCount}')

# Check if pod has restarted multiple times
if [ "$POD_RESTARTS" -lt 2 ]
then
  echo "Pod has not restarted multiple times. Current restart count: $POD_RESTARTS"
  exit 1
fi

# Check for misconfigurations in manifest file
if grep -q "env:" $K8S_MANIFEST || grep -q "volumeMounts:" $K8S_MANIFEST || grep -q "resources:" $K8S_MANIFEST
then
  echo "Misconfigurations found in manifest file: $K8S_MANIFEST"
  exit 0
else
  echo "No misconfigurations found in manifest file: $K8S_MANIFEST"
  exit 1
fi