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


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    echo 'root:030201' | chpasswd
    systemctl restart sshd
  EOF

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}














