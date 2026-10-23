variable "my_public_ip" {
  description = "Public IP allowed to SSH into the VM, in CIDR notation"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the local SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "docker_image" {
  description = "Docker Hub image to run on the VM"
  type        = string
}