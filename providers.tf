provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "docker" {}