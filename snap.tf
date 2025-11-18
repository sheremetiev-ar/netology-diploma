resource "yandex_compute_snapshot_schedule" "default" {
  name			= "diploma-snapshot-schedule"
  
  schedule_policy {
    expression = "30 7 ? * *"
  }
  disk_ids = ["fhm41meg512452nh5u5q", "epdssp06dgoarauti5s1", "fhm5kc0t90oh9m92s0a1", "fhmfomeomkb6a71snd78", "fhm03pmgqvj8bvedfss7", "fhmj22lpe0tm1oulirs2"]  
  retention_period = "168h"

}
