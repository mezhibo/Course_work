resource "yandex_vpc_security_group" "internal" {
  name       = "internal-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    description    = "allow any connection from internal subnets"
	  predefined_target = "self_security_group"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connections"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-bastion" {
  name       = "public-bastion-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "ssh_bastion"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-grafana" {
  name       = "public-grafana-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "allow grafana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }
  
  ingress {
    protocol       = "TCP"
    description    = "allow grafana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  } 

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-kibana" {
  name       = "public-kibana-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "allow kibana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public-load-balancer" {
  name       = "public-load-balancer-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    description    = "allow HTTP connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "allow ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}