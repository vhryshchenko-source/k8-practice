provider "google" {
  region      = var.region
  project     = var.project
  credentials = var.credential_path
}

provider "google-beta" {
  project     = var.project
  region      = var.region
  credentials = var.credential_path
}