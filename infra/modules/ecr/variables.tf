variable "project" {
    type = string
    default = "three-tier-app"
}

variable "tags" {
    description = "A map of tags to assign to the resources"
    type        = map(string)
    default     = {}
}