terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

####################
# NGINX DEPLOYMENT
####################

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }

    type = "NodePort"
  }
}

####################
# MYSQL DEPLOYMENT (HARDENED FOR KIND)
####################

resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0"

          port {
            container_port = 3306
          }

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "rootpassword"
          }

          # 🔥 REQUIRED FOR KIND STABILITY
          args = [
            "--default-authentication-plugin=mysql_native_password",
            "--skip-host-cache",
            "--skip-name-resolve",
            "--innodb-use-native-aio=0",
            "--innodb-flush-method=O_DIRECT_NO_FSYNC"
          ]

          readiness_probe {
            exec {
              command = ["bash", "-c", "mysqladmin ping -uroot -prootpassword"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          liveness_probe {
            exec {
              command = ["bash", "-c", "mysqladmin ping -uroot -prootpassword"]
            }
            initial_delay_seconds = 60
            period_seconds        = 20
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql-service"
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }

    type = "ClusterIP"
  }
}

####################
# OUTPUTS
####################

output "nginx_node_port" {
  value = kubernetes_service.nginx.spec[0].port[0].node_port
}

output "mysql_service_cluster_ip" {
  value = kubernetes_service.mysql.spec[0].cluster_ip
}
