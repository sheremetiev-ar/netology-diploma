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

# SECURITY GROUP BASTION
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

# SECURITY GROUP LAN
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

# SECURITY GROUP WEB-SERVERS
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

# SECURITY GROUP ELASTIC SEARCH
resource "yandex_vpc_security_group" "elastic-security-group" {
  name          = "elastic-security-group-diploma"
  network_id    = yandex_vpc_network.diploma.id

  ingress {
    description         = "Allow ELASTIC PORT"
    protocol            = "TCP"
    port                = 9200
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description         = "Allow ELASTIC PORT"
    protocol            = "TCP"
    port                = 9300
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP KIBANA
resource "yandex_vpc_security_group" "kibana-security-group" {
  name          = "kibana-security-group-diploma"
  network_id    = yandex_vpc_network.diploma.id

  ingress {
    description         = "Allow KIBANA PORT"
    protocol            = "TCP"
    port                = 5601
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP ZABBIX
resource "yandex_vpc_security_group" "zabbix-security-group" {
  name          = "zabbix-security-group-diploma"
  network_id    = yandex_vpc_network.diploma.id

  ingress {
    description         = "Allow ZABBIX AGENT PORT"
    protocol            = "TCP"
    port                = 10050
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description		= "Allow ZABBIX SERVER PORT"
    protocol		= "TCP"
    port		= 10051
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }
}

# SECURITY GROUP ZABBIX WEB-INTERFACE
resource "yandex_vpc_security_group" "zabbix-web-security-group" {
  name			= "zabbix-web-security-group-diploma"
  network_id		= yandex_vpc_network.diploma.id

  ingress {
    description         = "Allow ZABBIX WEB PORT"
    protocol            = "TCP"
    port                = 8080
    v4_cidr_blocks      = ["0.0.0.0/0"]
  }
}
