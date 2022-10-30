output "access_vpn_ipv4" {
  value = digitalocean_droplet.writeas_instance.ipv4_address
}
