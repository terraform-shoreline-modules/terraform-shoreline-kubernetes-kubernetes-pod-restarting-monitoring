terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "kubernetes_pod_restarting_monitoring" {
  source    = "./modules/kubernetes_pod_restarting_monitoring"

  providers = {
    shoreline = shoreline
  }
}