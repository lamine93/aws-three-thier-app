variable "name"  { 
    type = string 
}
variable "engine" { 
    type = string 
    default = "postgres" 
}
variable "engine_version" { 
    type = string 
    default = "16.3" 
}
variable "instance_class" { 
    type = string 
    default = "db.t4g.micro" 
}
variable "allocated_storage" {
    type = number 
    default = 20
}
variable "db_name"  { 
    type = string 
}
variable "db_username"  { 
    type = string 
}
variable "db_password"  { 
    type = string 
    sensitive = true 
}
variable "subnet_ids"   { 
    type = list(string) 
}
variable "security_group_ids"  { 
    type = list(string) 
}
variable "tags" {
    type = map(string)
}

variable "db_secret_id" {
    type = string
  
}


