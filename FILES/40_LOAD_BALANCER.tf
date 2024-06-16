resource "yandex_alb_http_router" "web-http-router" {
  name = "web-http-router"
}
resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "my-virtual-host"
  http_router_id = "${yandex_alb_http_router.web-http-router.id}"
  route {
    name = "core"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = "${yandex_alb_backend_group.web-backend-group.id}"
        timeout          = "3s"
      }
    }
  }
}
# Создаем Application Load Balancer (ALB)
resource "yandex_alb_load_balancer" "web-alb" {
  name = "web-alb"
  network_id  = yandex_vpc_network.vpc.id 
  security_group_ids = ["${yandex_vpc_security_group.internal.id}","${yandex_vpc_security_group.public-load-balancer.id}"] 

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.public-subnet.id}" 
    }
  }
  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.web-http-router.id}"
      }
    }
  }
}
