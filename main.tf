provider "kubernetes" {
  config_path = var.kubeconfig_path
}

#################################
# NGINX DEPLOYMENT
#################################

resource "kubernetes_deployment" "nginx" {
  wait_for_rollout = false

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

#################################
# NGINX SERVICE
#################################

resource "kubernetes_service" "nginx" {
  wait_for_load_balancer = false

  metadata {
    name = "nginx-service"
  }

  spec {
    selector = {
      app = "nginx"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }
  }
}

#################################
# MYSQL DEPLOYMENT
#################################

resource "kubernetes_deployment" "mysql" {
  wait_for_rollout = false

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

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "rootpassword"
          }

          port {
            container_port = 3306
          }
        }
      }
    }
  }
}

#################################
# MYSQL SERVICE
#################################

resource "kubernetes_service" "mysql" {
  wait_for_load_balancer = false

  metadata {
    name = "mysql-service"
  }

  spec {
    selector = {
      app = "mysql"
    }

    type = "ClusterIP"

    port {
      port        = 3306
      target_port = 3306
    }
  }
}
