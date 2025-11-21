# BASTION
resource "yandex_compute_instance" "bastion" {
  name		= "bastion"
  hostname	= "bastion"
  platform_id	= "standard-v3"
  zone		= "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores	   = 2
    memory	   = 1
    core_fraction  = 20
  }

  boot_disk {
    initialize_params {
      name	= "bastion-disk"
      image_id	= "fd86rorl7r6l2nq3ate6"
      type	= "network-hdd"
      size	= 10
    }
  }

  metadata = {
    user-data		= file("./cloud-init.yml")
    serial-port-enable	= 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id		= yandex_vpc_subnet.diploma-zone-a.id
    nat			= true
    security_group_ids	= [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.bastion.id, yandex_vpc_security_group.zabbix-security-group.id]
  }
}

# SERVER A
resource "yandex_compute_instance" "server-a" {
  name		= "server-a"
  hostname	= "server-a"
  platform_id	= "standard-v3"
  zone		= "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores		= 2
    memory		= 1
    core_fraction	= 20
  }

  boot_disk {
    initialize_params {
      name	= "server-a-disk"
      image_id	= "fd86rorl7r6l2nq3ate6"
      type	= "network-hdd"
      size	= 10
    }
  }

  metadata = {
    user-data		= file("./cloud-init.yml")
    serial-port-enable	= 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id		= yandex_vpc_subnet.diploma-zone-a.id
    nat			= false
    security_group_ids	= [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.servers-security-group.id, yandex_vpc_security_group.elastic-security-group.id, yandex_vpc_security_group.zabbix-security-group.id]
  }
}

# SERVER B
resource "yandex_compute_instance" "server-b" {
  name          = "server-b"
  hostname      = "server-b"
  platform_id   = "standard-v3"
  zone          = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    cores               = 2
    memory              = 1
    core_fraction       = 20
  }

  boot_disk {
    initialize_params {
      name	= "server-b-disk"
      image_id  = "fd86rorl7r6l2nq3ate6"
      type      = "network-hdd"
      size      = 10
    }
  }

  metadata = {
    user-data           = file("./cloud-init.yml")
    serial-port-enable  = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id           = yandex_vpc_subnet.diploma-zone-b.id
    nat                 = false
    security_group_ids  = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.servers-security-group.id, yandex_vpc_security_group.elastic-security-group.id, yandex_vpc_security_group.zabbix-security-group.id]
  }
}

# SERVER ELASTIC
resource "yandex_compute_instance" "elastic" {
  name          = "elastic"
  hostname      = "elastic"
  platform_id   = "standard-v3"
  zone          = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores               = 2
    memory              = 4
    core_fraction       = 20
  }

  boot_disk {
    initialize_params {
      name	= "elastic-disk"
      image_id  = "fd86rorl7r6l2nq3ate6"
      type      = "network-hdd"
      size      = 20
    }
  }

  metadata = {
    user-data           = file("./cloud-init.yml")
    serial-port-enable  = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id           = yandex_vpc_subnet.diploma-zone-a.id
    nat                 = false
    security_group_ids  = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.elastic-security-group.id, yandex_vpc_security_group.zabbix-security-group.id]
  }
}

# SERVER KIBANA
resource "yandex_compute_instance" "kibana" {
  name          = "kibana"
  hostname      = "kibana"
  platform_id   = "standard-v3"
  zone          = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores               = 2
    memory              = 2
    core_fraction       = 20
  }

  boot_disk {
    initialize_params {
      name	= "kibana-disk"
      image_id  = "fd86rorl7r6l2nq3ate6"
      type      = "network-hdd"
      size      = 10
    }
  }

  metadata = {
    user-data           = file("./cloud-init.yml")
    serial-port-enable  = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id           = yandex_vpc_subnet.diploma-zone-a.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.kibana-security-group.id, yandex_vpc_security_group.zabbix-security-group.id]
  }
}

# SERVER ZABBIX
resource "yandex_compute_instance" "zabbix" {
  name          = "zabbix"
  hostname      = "zabbix"
  platform_id   = "standard-v3"
  zone          = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores               = 2
    memory              = 2
    core_fraction       = 100
  }

  boot_disk {
    initialize_params {
      name	= "zabbix-disk"
      image_id  = "fd86rorl7r6l2nq3ate6"
      type      = "network-hdd"
      size      = 10
    }
  }

  metadata = {
    user-data           = file("./cloud-init.yml")
    serial-port-enable  = 1
  }

  scheduling_policy { preemptible = false }

  network_interface {
    subnet_id           = yandex_vpc_subnet.diploma-zone-a.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.zabbix-security-group.id, yandex_vpc_security_group.zabbix-web-security-group.id]
  }
}


# ANSIBLE INVENTORY
resource "local_file" "inventory" {
  content = <<-XYZ
[bastion]
${yandex_compute_instance.bastion.fqdn} ansible_host=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

[webservers]
${yandex_compute_instance.server-a.fqdn}
${yandex_compute_instance.server-b.fqdn}

[zabbix]
${yandex_compute_instance.zabbix.fqdn}

[elasticsearch]
${yandex_compute_instance.elastic.fqdn}

[kibana]
${yandex_compute_instance.kibana.fqdn}

[all:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'

XYZ
filename= "./hosts.ini"
}
