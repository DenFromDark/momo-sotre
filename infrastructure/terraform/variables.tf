variable "cloud_id" {
  description = "CLOUD ID"
  type        = string
}

variable "folder_id" {
  description = "FOLDER ID"
  type        = string
}

variable "network_zone" {
  description = "Yandex.Cloud network availability zones"
  type        = string
  default     = "ru-central1-a"
  validation {
    condition     = contains(toset(["ru-central1-a", "ru-central1-b", "ru-central1-c"]), var.network_zone)
    error_message = "Select availability zone from the list: ru-central1-a, ru-central1-b, ru-central1-c."
  }
  sensitive = true
  nullable  = false
}

variable "token" {
  type = string
  sensitive = true
}

variable "k8s_version" {
  type = string
  default = "1.23"
}

variable "scale_size" {
  type = string
  default = "2"
}

variable "node_memory" {
  type = string
  default = "2"
}

variable "node_cores" {
  type = string
  default = "2"
}

variable "node_day_maintenance" {
  type = string
  default = "monday"
}

variable "node_hour_maintenance" {
  type = string
  default = "02:00"
}

variable "node_duration_maintenance" {
  type = string
  default = "2h"
}