resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  platform_id = "standard-v3"
  zone = "ru-central1-a"
  resources {
    core_fraction = 50 
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd8idq8k33m9hlj0huli"
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.internal.id}","${yandex_vpc_security_group.public-bastion.id}"]
  }
  metadata = {
    foo = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}