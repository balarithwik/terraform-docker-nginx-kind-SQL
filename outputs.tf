output "nginx_node_port" {
  value = kubernetes_service.nginx.spec[0].port[0].node_port
}

output "mysql_service_cluster_ip" {
  value = kubernetes_service.mysql.spec[0].cluster_ip
}
