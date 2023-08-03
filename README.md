
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Pod Restarting Monitoring
---

A Kubernetes Pod Restarting Monitoring incident is triggered when a pod running on a Kubernetes cluster restarts multiple times within a certain time frame. This incident type is usually used to detect issues with the application or infrastructure running on the cluster, and can be caused by various factors such as resource constraints, misconfigurations, or bugs in the application code. The incident is typically resolved by identifying and addressing the underlying cause of the pod restarts.

### Parameters
```shell
# Environment Variables
export POD_NAMESPACE="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export CONTAINER_NAME="PLACEHOLDER"
export K8S_MANIFEST_FILE="PLACEHOLDER"
```

## Debug

### List all pods in <namespace>
```shell
kubectl get pods -n ${POD_NAMESPACE}
```

### Get detailed information about a specific pod
```shell
kubectl describe pod ${POD_NAME} -n ${POD_NAMESPACE}
```

### View the logs for a specific container in a pod
```shell
kubectl logs ${POD_NAME} ${CONTAINER_NAME} -n ${POD_NAMESPACE}
```

### View the events related to a specific pod
```shell
kubectl get events -n ${POD_NAMESPACE} --field-selector involvedObject.name=${POD_NAME}
```

### View the metrics for a specific pod
```shell
kubectl top pod ${POD_NAME} -n ${POD_NAMESPACE}
```

### Misconfigurations: The pod may be restarting due to misconfigurations in the Kubernetes manifest files, such as incorrect environment variables or volume mounts. This may also be caused by misconfigured resource requests or limits.
```shell

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

```

### Resource constraints: The pod may be restarting due to insufficient resources such as CPU or memory. This may be due to high resource usage by other pods running on the same node or cluster, or because the pod's resource requests or limits are not properly configured.
```shell

#!/bin/bash

# STEP 1: Get the name and namespace of the pod to diagnose
pod_name="${POD_NAME}"
pod_namespace="${POD_NAMESPACE}"

# STEP 2: Get the name of the node where the pod is running
node_name=$(kubectl get pod $pod_name -n $pod_namespace -o jsonpath='{.spec.nodeName}')

# STEP 3: Check the resource usage of the node
kubectl top node $node_name

# STEP 4: Check the resource requests and limits of the pod
kubectl describe pod $pod_name -n $pod_namespace | grep -E "Limits:|Requests:"

```

---

## Repair
---

### Adjust the memory requests and limits.
```shell
#!/bin/bash

# Set the deployment, container, request memory, and limit memory variables
deployment_name="PLACEHOLDER"
container_name="PLACEHOLDER"
request_memory="PLACEHOLDER"
limit_memory="2GPLACEHOLDERi"

# Patch the deployment with the specified memory settings
kubectl patch deployment "$deployment_name" -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"$container_name\",\"resources\":{\"requests\":{\"memory\":\"$request_memory\"},\"limits\":{\"memory\":\"$limit_memory\"}}}]}}}}"

```

---