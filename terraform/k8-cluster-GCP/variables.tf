#Credentials
variable "project" {}

variable "region" {}

variable "credential_path" {}

# Parameters
variable "cluster_name" {
  default = "gke-cluster"
}

variable "cluster_region" {
  default = "us-central1"

}
variable "node_zones" {
  type    = list(string)
  default = ["us-central1-a"]
}

variable "node_count" {
  type    = number
  default = 1
}


variable "machine_type" {
  default = "e2-small"
}