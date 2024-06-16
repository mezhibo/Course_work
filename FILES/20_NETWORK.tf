resource "yandex_vpc_network" "vpc" {
  name = "vpc-network"
}
resource "yandex_vpc_route_table" "nat-bastion" {
  network_id = "${yandex_vpc_network.vpc.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "${yandex_compute_instance.bastion.network_interface.0.ip_address}"
  }
}
# Создание публичной подсети
resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}
# Создание приватной подсети для Web, Prometheus, Elasticsearch серверов
resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = "${yandex_vpc_route_table.nat-bastion.id}"
}
resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = "${yandex_vpc_route_table.nat-bastion.id}"
}
# Создаем Target Group
resource "yandex_alb_target_group" "web-target-group" {
  name = "web-target-group"

  target {
    subnet_id = "${yandex_compute_instance.webserver-1.network_interface.0.subnet_id}"
    ip_address   = "${yandex_compute_instance.webserver-1.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_compute_instance.webserver-2.network_interface.0.subnet_id}"
    ip_address   = "${yandex_compute_instance.webserver-2.network_interface.0.ip_address}"
  }
}
# Создаем Backend Group и настраиваем health checks
resource "yandex_alb_backend_group" "web-backend-group" {
  name = "web-backend-group"
  http_backend {
    name        = "backend1"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.web-target-group.id}"]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout = "10s"
      interval = "5s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}