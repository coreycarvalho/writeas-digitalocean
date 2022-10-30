terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.22.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.22"
    }
  }

  required_version = "~> 1.2"
}
