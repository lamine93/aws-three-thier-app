variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for static website hosting"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources"
}
