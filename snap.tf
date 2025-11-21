resource "yandex_compute_snapshot_schedule" "default" {
  name			= "diploma-snapshot-schedule"
  
  schedule_policy {
    expression = "30 7 ? * *"
  }
  disk_ids = [yandex_compute_instance.elastic.boot_disk[0].disk_id,
	      yandex_compute_instance.bastion.boot_disk[0].disk_id,
	      yandex_compute_instance.server-a.boot_disk[0].disk_id,
	      yandex_compute_instance.server-b.boot_disk[0].disk_id,  
	      yandex_compute_instance.kibana.boot_disk[0].disk_id,
              yandex_compute_instance.zabbix.boot_disk[0].disk_id]

  retention_period = "168h"

}
