variable "region" {
    type = string
}

variable "app_port" {
    type    = number  
}

variable "db_password"  { 
    type = string 
    sensitive = true
}

variable "project" {
    type = string
}

variable "engine_version" {
    type    = string
}

variable "instance_class" {
    type    = string
}

variable "db_name" {
    type = string
}

variable "db_username" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "public_cidrs" {
    type = list(string)
}

variable "private_cidrs" {
    type = list(string)
}

variable "tags" {
    type = map(string)
}

variable "asm_name" {
    type = string
}