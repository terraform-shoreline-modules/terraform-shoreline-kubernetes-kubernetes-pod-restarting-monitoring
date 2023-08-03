
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