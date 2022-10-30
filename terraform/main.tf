terraform {
  backend "s3" {
    bucket = "corey-terraform-state"
    key    = "writeas-digitalocean"
    region = "us-east-2"
  }
}

data "digitalocean_ssh_key" "corey_mb_air" {
  name = "corey-personal-mb-air"
}

data "digitalocean_ssh_key" "corey_mb_air_ed25519" {
  name = "corey-personal-mb-air-ed25519"
}

resource "digitalocean_vpc" "writeas" {
  name     = "writeas"
  region   = "nyc1"
  ip_range = "10.0.0.0/24"
}

resource "digitalocean_droplet" "writeas_instance" {
  image    = "ubuntu-22-04-x64"
  name     = "writeas-blog"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.corey_mb_air.id, data.digitalocean_ssh_key.corey_mb_air_ed25519.id]
  vpc_uuid = digitalocean_vpc.writeas.id
}

data "cloudflare_zone" "coreycarvalho_com" {
  name = "coreycarvalho.com"
}

resource "cloudflare_record" "writeas" {
  zone_id = data.cloudflare_zone.coreycarvalho_com.id
  name    = "vpn"
  value   = "vpn-137-184-60-172.warpspeedvpn.com"
  type    = "CNAME"
  proxied = false
}

resource "digitalocean_firewall" "writeas_instance" {
  name = "writeas-instance"

  droplet_ids = [digitalocean_droplet.writeas_instance.id]

 ##TODO change this to my VPN address
 inbound_rule {
   protocol         = "tcp"
   port_range       = "22"
   source_addresses = ["0.0.0.0/0"]
 }

  inbound_rule {
    protocol         = "udp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
