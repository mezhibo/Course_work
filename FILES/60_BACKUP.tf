resource "yandex_compute_snapshot_schedule" "my-snapshot-disk" {
  name           = "my-snapshot-disk"
  schedule_policy {
	expression = "0 10 * * *"
  }
  snapshot_count = 7
  labels = {
    my-label = "my-label-value"
  }

  disk_ids = ["${yandex_compute_instance.webserver-1.boot_disk.0.disk_id}",
  "${yandex_compute_instance.webserver-2.boot_disk.0.disk_id}",
  "${yandex_compute_instance.bastion.boot_disk.0.disk_id}","${yandex_compute_instance.prometheus-server.boot_disk.0.disk_id}",
  "${yandex_compute_instance.elasticsearch-server.boot_disk.0.disk_id}",
  "${yandex_compute_instance.kibana-server.boot_disk.0.disk_id}",
  "${yandex_compute_instance.grafana-server.boot_disk.0.disk_id}"]
  depends_on = [yandex_alb_load_balancer.web-alb]
} 