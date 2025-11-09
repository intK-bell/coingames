variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the table."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "partition_key" {
  description = "Partition key definition."
  type = object({
    name = string
    type = string
  })
}

variable "sort_key" {
  description = "Sort key definition."
  type = object({
    name = string
    type = string
  })
  default  = null
  nullable = true
}

variable "ttl_attribute" {
  description = "Optional TTL attribute name."
  type        = string
  default     = null
  nullable    = true
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery."
  type        = bool
  default     = true
}

variable "enable_stream" {
  description = "Enable DynamoDB streams."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type when streams are enabled."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "global_secondary_indexes" {
  description = "List of GSI definitions."
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags to attach to the table resources."
  type        = map(string)
  default     = {}
}
