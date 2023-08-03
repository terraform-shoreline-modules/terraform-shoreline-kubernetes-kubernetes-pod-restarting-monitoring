resource "shoreline_notebook" "kubernetes_pod_restarting_monitoring" {
  name       = "kubernetes_pod_restarting_monitoring"
  data       = file("${path.module}/data/kubernetes_pod_restarting_monitoring.json")
  depends_on = [shoreline_action.invoke_pods_check_script,shoreline_action.invoke_pod_resources,shoreline_action.invoke_memory_patch]
}

resource "shoreline_file" "pods_check_script" {
  name             = "pods_check_script"
  input_file       = "${path.module}/data/pods_check_script.sh"
  md5              = filemd5("${path.module}/data/pods_check_script.sh")
  description      = "Misconfigurations: The pod may be restarting due to misconfigurations in the Kubernetes manifest files, such as incorrect environment variables or volume mounts. This may also be caused by misconfigured resource requests or limits."
  destination_path = "/agent/scripts/pods_check_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "pod_resources" {
  name             = "pod_resources"
  input_file       = "${path.module}/data/pod_resources.sh"
  md5              = filemd5("${path.module}/data/pod_resources.sh")
  description      = "Resource constraints: The pod may be restarting due to insufficient resources such as CPU or memory. This may be due to high resource usage by other pods running on the same node or cluster, or because the pod's resource requests or limits are not properly configured."
  destination_path = "/agent/scripts/pod_resources.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "memory_patch" {
  name             = "memory_patch"
  input_file       = "${path.module}/data/memory_patch.sh"
  md5              = filemd5("${path.module}/data/memory_patch.sh")
  description      = "Adjust the memory requests and limits."
  destination_path = "/agent/scripts/memory_patch.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pods_check_script" {
  name        = "invoke_pods_check_script"
  description = "Misconfigurations: The pod may be restarting due to misconfigurations in the Kubernetes manifest files, such as incorrect environment variables or volume mounts. This may also be caused by misconfigured resource requests or limits."
  command     = "`chmod +x /agent/scripts/pods_check_script.sh && /agent/scripts/pods_check_script.sh`"
  params      = ["POD_NAME","POD_NAMESPACE","K8S_MANIFEST_FILE"]
  file_deps   = ["pods_check_script"]
  enabled     = true
  depends_on  = [shoreline_file.pods_check_script]
}

resource "shoreline_action" "invoke_pod_resources" {
  name        = "invoke_pod_resources"
  description = "Resource constraints: The pod may be restarting due to insufficient resources such as CPU or memory. This may be due to high resource usage by other pods running on the same node or cluster, or because the pod's resource requests or limits are not properly configured."
  command     = "`chmod +x /agent/scripts/pod_resources.sh && /agent/scripts/pod_resources.sh`"
  params      = ["POD_NAME","POD_NAMESPACE"]
  file_deps   = ["pod_resources"]
  enabled     = true
  depends_on  = [shoreline_file.pod_resources]
}

resource "shoreline_action" "invoke_memory_patch" {
  name        = "invoke_memory_patch"
  description = "Adjust the memory requests and limits."
  command     = "`chmod +x /agent/scripts/memory_patch.sh && /agent/scripts/memory_patch.sh`"
  params      = []
  file_deps   = ["memory_patch"]
  enabled     = true
  depends_on  = [shoreline_file.memory_patch]
}

