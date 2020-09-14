# Setting an provider
provider "google" {
  credentials = file(var.credentials_file_path)
  project = var.org_id
  region = var.region
}

# Creating First VPC Network
resource "google_compute_network" "network" {
  name = "${var.project_name}-${var.env}-network"
  description = "${var.project_name} Network"
  project = var.org_id
  routing_mode = "REGIONAL"
  auto_create_subnetworks = false
}

# Creating Subnetwork for First VPC
resource "google_compute_subnetwork" "subnet" {
  name = "${var.project_name}-${var.env}-subnet"
  ip_cidr_range = var.subnet_range
  project = var.org_id
  region = var.region
  network = google_compute_network.network.id

  depends_on = [
    google_compute_network.network
  ]
}


# Create Firewall VPC Network
resource "google_compute_firewall" "network-firewall" {
  name = "${var.project_name}-${var.env}-network-firewall"
  network = google_compute_network.network.id

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["22", "80", "443", "9000"]
  }

  source_tags = ["${var.project_name}", "network"]

  depends_on = [
    google_compute_network.network
  ]
}

# Creating Firewall VPC Network Subnet
resource "google_compute_firewall" "subnet-firewall" {
  name = "${var.project_name}-${var.env}-subnetwork-firewall"
  network = google_compute_network.network.id

  source_ranges = ["${var.subnet_range}"]

  allow {
    protocol = "tcp"
    ports = ["22", "9000", "8000", "9001", "80", "7946", "53", "2377", "2376"]
  }

  allow {
    protocol = "udp"
    ports = ["7946", "4789", "53"]
  }

  source_tags = ["${var.project_name}", "subnet"]

  depends_on = [
    google_compute_network.network
  ]
}

# Set addresses for managers instances
resource "google_compute_address" "managers_addresses" {
  count = var.manager_count
  name = "${var.project_name}-${var.env}-manager-${count.index}"
  subnetwork = google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
  address = "10.0.4.${count.index+2}"
  region = "us-central1"
}

# Set addresses for worker instances
resource "google_compute_address" "workers_addresses" {
  count = var.worker_count
  name = "${var.project_name}-${var.env}-worker-${count.index}"
  subnetwork = google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
  address = "10.0.4.${count.index+10}"
  region = "us-central1"
}

# Create VM manager instances
resource "google_compute_instance" "manager" {
  count = var.manager_count
  name = "${var.project_name}-${var.env}-manager-${count.index}"
  machine_type = "n1-standard-1"
  zone = var.region_zone

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = var.project_image
      size = var.project_boot_disk_size
      type = vat.project_boot_disk_type
    }
  }

  network_interface {
    network = google_compute_network.network.name
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.managers_addresses["${count.index}"].address
    access_config {
      network_tier = "STANDARD"
    }
  }

  metadata = {
    ssh-keys = "root:${file(var.public_key_path)}"
  }

  provisioner "file" {
    source = var.install_script_src_path
    destination = var.install_script_dest_path

    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "root"
      private_key = file(var.private_key_path)
      agent = false
    }
  }

  provisioner "remote-exec" {
    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "root"
      private_key = file(var.private_key_path)
      agent = false
    }

    inline = [
      "chmod +x ${var.install_script_dest_path}",
      "sudo ${var.install_script_dest_path}",
    ]
  }

  //service_account {
  //  scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  //}
}

# Create VM worker instances
resource "google_compute_instance" "worker" {
  count = var.worker_count
  name = "${var.project_name}-${var.env}-worker-${count.index}"
  machine_type = "n1-standard-1"
  zone = var.region_zone

  tags = ["worker", "${var.project_name}"]

  boot_disk {
    initialize_params {
      image = var.project_image
      size = var.project_boot_disk_size
      type = var.project_boot_disk_type
    }
  }

  network_interface {
    network = google_compute_network.network.name
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.workers_addresses["${count.index}"].address
    access_config {
      network_tier = "STANDARD"
    }
  }

  metadata = {
    ssh-keys = "root:${file(var.public_key_path)}"
  }

  provisioner "file" {
    source = var.install_script_src_path
    destination = var.install_script_dest_path

    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "root"
      private_key = file(var.private_key_path)
      agent = false
    }

  }

  provisioner "remote-exec" {
    connection {
      host = self.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "root"
      private_key = file(var.private_key_path)
      agent = false
    }

    inline = [
      "chmod +x ${var.install_script_dest_path}",
      "sudo ${var.install_script_dest_path} ${count.index}",
    ]
  }	
}