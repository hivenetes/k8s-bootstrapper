# DO API Token
variable "do_token" {}

variable "name" {
    type = string
}

variable "region" {
    type        = string
    default     = "ams3"
}

variable "k8s_version" {
    type        = string
    default = "1.25.4-do.0"
}

variable "vpc_uuid" {
    type        = string
    default     = null
}

variable "auto_upgrade" {
    type        = bool
    default     =   false
}

variable "surge_upgrade" {
    type        = bool
    default     = false
}

variable "ha" {
    type        = bool
    default     = true
}

variable "node_pool" {
    type        = map
    default =   {
        name = "island-pool"
        # `doctl compute size list` for droplet sizes and types
        size = "s-8vcpu-16gb-amd"
        node_count = 3
        auto_scale = true
        min_nodes = 3
        max_nodes = 5
    }
}

variable "tags" {
    type        = list(string)
    default =   null
}

# DOCR
variable "container_registry" {
    type        = string
    default =   "hivenetes-cr"
}
