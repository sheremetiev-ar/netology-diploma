#        APPLICATION 
#        LOAD
#        BALANCER


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
  name          = "servers-app-load-balancer"
  network_id    = yandex_vpc_network.diploma.id

  allocation_policy {
    location {
      zone_id           = "ru-central1-a"
      subnet_id         = yandex_vpc_subnet.diploma-zone-a.id
    }
    location {
      zone_id           = "ru-central1-b"
      subnet_id         = yandex_vpc_subnet.diploma-zone-b.id
    }
  }

  listener {
    name                = "http-listener"
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
