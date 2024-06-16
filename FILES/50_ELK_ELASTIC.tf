resource "yandex_compute_instance" "elasticsearch-server" {
  name = "elasticsearch-server"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 100 
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 50
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