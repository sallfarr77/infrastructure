terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

variable "gcp-cred" {
  description = "Google Cloud Platform Credentials"
  type        = string
}

provider "google" {
  credentials = var.gcp-cred

  project = "development-404506"
  region  = "asia-southeast2"
  zone    = "asia-southeast2-a"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

variable "gce_ssh_user" {
  type    = string
  default = "salman"
}

variable "gce_ssh_pub_key_file" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCp0THegmAUdowXe9g+MJIlt8qyBoPiHVUfzKFwEX0W6nrno8HL2tRGYfszodJHfu5PZxyuowjMX8iOeY1rJMOx8UwUceLYZT7knvio/Kapqgxy0cJ92Hy/aw85P5niGpE/w8nmoRuvOfMBQZk8Q8JcRMXrTQIkFI7wlq4yR2MH2OXCkjcqbWQxChThS2xCzFGlkR3qMyWhxMPKiYWFbwXUWxbCS05kabSKeHYY4dg02SwnczRJotfD0od2Lq4rhWKnYgvpWgCKUbvgomTXP/6JqfrGicAAp1l4QT+mDTq7OhoKjxNY6nvuKVmq010MQWTkzXZBhtwamPQNe7XgEU9K0kviOHDhsRRtGfxeZhZWaXOiNKeer4w1MWcsnD0CHUqoZjoNJhDaJBjbHh6xAsOn7O74GHhdxwSth0YJax1+DIH1A9J1Z1yjVE7/DT2X+WvD0iJE6bYGSdKJbFS4Z6sIcG2Bm8PV1jXtfc9hzLOtWPfF55xsVzOajISG5Gf8dkU= sallfarr@DESKTOP-79GAIUS"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
      size  = 100
    }
  }

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${var.gce_ssh_pub_key_file}"
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {}
  }
}

resource "google_compute_address" "static_ip" {
  name   = "terraform-static-ip"
  region = "asia-southeast2"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

