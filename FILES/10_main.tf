terraform {
  required_version = "= 1.8.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.120"
    }
  }
}

provider "yandex" {
  token     = "y0_AgAAAABgEjtLAATuwQAAAAEFw4ajAACKU9vWqBpFY6fqbFGKbmGDTL7KlQ"
  cloud_id  = "b1gvqb4s3f495f55ih0b"
  folder_id = "b1glq93bir0j2f0sl892"
  zone      = "ru-central1-a"
}
