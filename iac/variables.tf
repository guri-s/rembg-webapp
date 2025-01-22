# Variables

variable "org_id" {
  description = "The ID of the Organization"
  type        = string
}

variable "project_id" {
  description = "The ID of the project"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "The default region for resources"
  type        = string
  default     = "us-central1"
}

variable "billing_account_id" {
  description = "The ID of the billing account to associate with the project"
  type        = string
}

variable "repository_id" {
  description = "The ID of the Artifact Registry repository"
  type        = string
}
variable "google_cloud_run_service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "service_account_id" {
  description = "The Service Account ID for Cloud Run Service Account"
  type        = string
}

variable "service_account_name" {
  description = "The Service Account Name for Cloud Run Service Account"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker Image Tag"
  type        = string
}

variable "docker_image_name" {
  description = "Docker Image Name"
  type        = string
}
