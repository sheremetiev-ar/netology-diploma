# VIRTUAL PRIVATE CLOUD
resource "yandex_vpc_network" "diploma" {
  name = "diploma-vpc-network"
}

# SUBNET ZONE A
resource "yandex_vpc_subnet" "diploma-zone-a" {
  name			= "develop-fops-diploma-ru-central1-a"
  zone			= "ru-central1-a"
  network_id		= yandex_vpc_network.diploma.id
  v4_cidr_blocks	= ["10.0.1.0/24"]
  route_table_id	= yandex_vpc_route_table.diploma-rt.id
}

# SUBNET ZONE B
resource "yandex_vpc_subnet" "diploma-zone-b" {
  name                  = "develop-fops-diploma-ru-central1-b"
  zone                  = "ru-central1-b"
  network_id            = yandex_vpc_network.diploma.id
  v4_cidr_blocks        = ["10.0.2.0/24"]
  route_table_id        = yandex_vpc_route_table.diploma-rt.id
}

# NAT GATEWAY
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "fops-gateway-diploma"
  shared_egress_gateway {}
}

# ROUTE TABLE
resource "yandex_vpc_route_table" "diploma-rt" {
  name			= "fops-route-table-diploma"
  network_id		= yandex_vpc_network.diploma.id
  
  static_route {
    destination_prefix  = "0.0.0.0/0"
    gateway_id	        = yandex_vpc_gateway.nat_gateway.id
  }
}

# SECURITY GROUP
resource "yandex_vpc_security_group" "bastion" {
  name		= "bastion-security-group-diploma"
  network_id	= yandex_vpc_network.diploma.id
  ingress {
    description		= "Allow 0.0.0.0/0"
    protocol		= "TCP"
    v4_cidr_blocks	= ["0.0.0.0/0"]
    port		= 22
  }
  egress {
    description		= "Permit ANY"
    protocol		= "ANY"
    v4_cidr_blocks	= ["0.0.0.0/0"]
    from_port		= 0
    to_port		= 65535
  }
}

resource "yandex_vpc_security_group" "LAN" {
  name          = "LAN-security-group-diploma"
  network_id    = yandex_vpc_network.diploma.id
  ingress {
    description         = "Allow 10.0.0.0/8"
    protocol            = "ANY"
    v4_cidr_blocks      = ["10.0.0.0/8"]
    from_port           = 0
    to_port		= 65535
  }
  egress {
    description         = "Permit ANY"
    protocol            = "ANY"
    v4_cidr_blocks      = ["0.0.0.0/0"]
    from_port           = 0
    to_port             = 65535
  }
}

resource "yandex_vpc_security_group" "servers-security-group" {
  name		= "servers-security-group-diploma"
  network_id	= yandex_vpc_network.diploma.id

  ingress {
    description		= "Allow HTTPS"
    protocol		= "TCP"
    port		= 443
    v4_cidr_blocks	= ["0.0.0.0/0"]
  }
  ingress {
    description		= "Allow HTTP"
    protocol		= "TCP"
    port		= 80
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }

}


#        APPLICATION 
#	 LOAD
#  	 BALANCER


# TARGET GROUP
resource "yandex_alb_target_group" "servers-tg" {
  name = "server-target-group-a"
  
  target {
    subnet_id = yandex_vpc_subnet.diploma-zone-a.id
    ip_address = yandex_compute_instance.server-a.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.diploma-zone-b.id
    ip_address = yandex_compute_instance.server-b.network_interface.0.ip_address
  }
}

# BACKEND GROUP 
resource "yandex_alb_backend_group" "servers-bg" {
  name = "server-backend-group"

  http_backend {
    name             = "servers-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.servers-tg.id}"]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout  = "1s"
      interval = "1s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP ROUTER
resource "yandex_alb_http_router" "servers-hr" {
  name = "servers-http-router"
}

# VIRTUAL HOST
resource "yandex_alb_virtual_host" "servers-vhost" {
  name           = "servers-virtual-host"
  http_router_id = yandex_alb_http_router.servers-hr.id

  route {
    name = "servers-route"
    http_route {
      http_match {
        path {
          exact = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.servers-bg.id
      }
    }
  }
}

# APPLICATION LOAD BALANCER
resource "yandex_alb_load_balancer" "servers-alb" {
  name		= "servers-app-load-balancer"
  network_id	= yandex_vpc_network.diploma.id
  
  allocation_policy {
    location {
      zone_id		= "ru-central1-a"
      subnet_id		= yandex_vpc_subnet.diploma-zone-a.id
    }
    location {
      zone_id		= "ru-central1-b"
      subnet_id		= yandex_vpc_subnet.diploma-zone-b.id
    }
  }

  listener {
    name		= "http-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.servers-hr.id
      }
    }
  }
} 

