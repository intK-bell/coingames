locals {
  gsi_defaults = {
    non_key_attributes = []
  }
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.partition_key.name
  range_key    = var.sort_key == null ? null : var.sort_key.name

  stream_enabled   = var.enable_stream
  stream_view_type = var.enable_stream ? var.stream_view_type : null

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute == null ? [] : [var.ttl_attribute]
    content {
      attribute_name = ttl.value
      enabled        = true
    }
  }

  attribute {
    name = var.partition_key.name
    type = var.partition_key.type
  }

  dynamic "attribute" {
    for_each = var.sort_key == null ? [] : [var.sort_key]
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = try(global_secondary_index.value.range_key, null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = try(global_secondary_index.value.non_key_attributes, local.gsi_defaults.non_key_attributes)
    }
  }

  tags = var.tags
}
