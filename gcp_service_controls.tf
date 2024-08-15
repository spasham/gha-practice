provider "google" {
  project = var.project_id
  region  = var.region
}

# Fetch Existing VPC Network
data "google_compute_network" "existing_vpc" {
  name = var.existing_vpc_name
}

# Fetch Existing Subnetwork (Optional)
data "google_compute_subnetwork" "existing_subnetwork" {
  name    = var.existing_subnet_name
  network = data.google_compute_network.existing_vpc.id
  region  = var.region
}

# Create an Access Policy
resource "google_access_context_manager_access_policy" "access_policy" {
  parent = "organizations/${var.organization_id}"
  title  = "example-access-policy"
}

# Create an Access Level
resource "google_access_context_manager_access_level" "access_level" {
  name   = "example-access-level"
  parent = google_access_context_manager_access_policy.access_policy.name

  basic {
    conditions {
      ip_subnetworks = [data.google_compute_subnetwork.existing_subnetwork.ip_cidr_range]
    }
  }
}

# Create a Service Perimeter for Existing Projects and VPC
resource "google_access_context_manager_service_perimeter" "service_perimeter" {
  name           = "example-service-perimeter"
  parent         = google_access_context_manager_access_policy.access_policy.name
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  status {
    resources = [
      "projects/${var.project_id_1}",
      "projects/${var.project_id_2}"
      # Add more projects as needed
    ]

    access_levels = [
      google_access_context_manager_access_level.access_level.name
    ]

    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com"
      # Add more services as needed
    ]

    vpc_accessible_services {
      allowed_services = ["*"]
    }
  }
}



###VARIABLE.TF###

variable "project_id" {
  description = "The ID of the main project."
  type        = string
}

variable "region" {
  description = "The region where the resources are located."
  type        = string
  default     = "us-central1"
}

variable "organization_id" {
  description = "The ID of the organization."
  type        = string
}

variable "existing_vpc_name" {
  description = "The name of the existing VPC."
  type        = string
}

variable "existing_subnet_name" {
  description = "The name of the existing subnet."
  type        = string
}

variable "project_id_1" {
  description = "The ID of the first project to include in the service perimeter."
  type        = string
}

variable "project_id_2" {
  description = "The ID of the second project to include in the service perimeter."
  type        = string
}

# Add more project IDs as needed
