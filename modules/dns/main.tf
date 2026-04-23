resource "dns2api_records" "records" {
  for_each = var.records

  fqdn = each.value.fqdn

  record {
    ttl  = each.value.ttl
    type = each.value.type
    data = each.value.data
  }
}