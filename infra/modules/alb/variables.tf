variable "project" {
    type = string
    default = "three-tier-app"
}

variable "app_port" {
    type = number
}

variable "vpc_id" {
    type = string
}

variable "alb_sg_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
}

variable "tags" {
    description = "A map of tags to assign to the resources"
    type        = map(string)
    default     = {}
}