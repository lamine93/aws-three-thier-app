# modules/ecs_service/variables.tf (extraits)
variable "repo_url"         { type = string }
variable "app_port"         { type = number }
variable "cpu"              { type = number }
variable "memory"           { type = number }
variable "subnet_ids"       { type = list(string) }
variable "ecs_sg_id"        { type = string }
variable "target_group_arn" { type = string }
variable "log_group_name"   { type = string }
variable "assign_public_ip" { 
    type = bool 
    default = false 
}
variable "project" {
    type = string
    default = "three-tier-app"
}

variable "region" {
    type = string  
}

variable "secret_arn" {
    type = string
}

