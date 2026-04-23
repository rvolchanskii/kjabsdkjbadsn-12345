output "records" {
  description = "Created DNS records"
  value = {
    for key, record in dns2api_records.records : key => {
      fqdn = record.fqdn
      id   = record.id
    }
  }
}

output "record_count" {
  description = "Number of DNS records created"
  value       = length(dns2api_records.records)
}