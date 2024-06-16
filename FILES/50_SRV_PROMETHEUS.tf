resource "yandex_compute_instance" "prometheus-server" {
  name = "prometheus-server"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 50 
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 30
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    #nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}"]
  }
  metadata = {
    foo = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}