variable "region" {
  default = "us-central1"
}

variable "region_zone" {
  default = "us-central1-c"
}

variable "org_id" {
  description = "The ID of the Google Cloud Organization."
	default = "project_id"
}

variable "credentials_file_path" {
	description = "Location of the credentials to use. (auth json file)"
	default = "auth_file.json"
}

variable "vpc_routing_mode" {
	description = "VPC routing mode, can be REGIONAL (default) or GLOBAL"
	default	= "REGIONAL"
}

variable "env" {
	description = "Set type of environment, like staging, production... etc"
	default	= "development"
}

variable "project_name" {
	description = "Name project"
	default	= "project"
}

variable "subnet_range" {
	description = "Subnetwork ip range"
	default	= "10.0.4.0/24"
}

variable "install_script_src_path" {
	description = "Path to install script within this repository"
	default = "./scripts/docker.sh"
}

variable "install_script_dest_path" {
  description = "Path to put the install script on each destination resource"
  default = "/tmp/docker.sh"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default = "~/.ssh/rsa_id.pub"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default = "~/.ssh/rsa_id"
}

variable "project_image" {
	description = "Image used by whole project"
	default	= "debian-cloud/debian-10"
}

variable "project_boot_disk_size" {
	description = "Boot disk size"
	default = 10 //GiB
}

variable "project_boot_disk_type" {
	description = "Boot disk type"
	default = "pd-standard" //options: pd-ssd or pd-standard
}

variable "manager_count" {
	description = "Number of manage instances to be created"
	default = 1
}

variable "worker_count" {
	description = "Number of worker instances to be created"
	default = 1
}
