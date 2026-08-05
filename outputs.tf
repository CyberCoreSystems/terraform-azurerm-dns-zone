output "zone_id" {
  description = "Resource ID of the DNS zone."
  value       = azurerm_dns_zone.this.id
}

output "zone_name" {
  description = "Name of the DNS zone."
  value       = azurerm_dns_zone.this.name
}

output "name_servers" {
  description = "Authoritative Azure name servers for the zone. Create matching NS (delegation) records for this domain at your registrar (or in the parent zone) so the public internet resolves it."
  value       = azurerm_dns_zone.this.name_servers
}

output "number_of_record_sets" {
  description = "Current number of record sets in the zone (includes the auto-created SOA and apex NS)."
  value       = azurerm_dns_zone.this.number_of_record_sets
}

output "max_number_of_record_sets" {
  description = "Maximum number of record sets allowed in the zone."
  value       = azurerm_dns_zone.this.max_number_of_record_sets
}

output "a_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each A record."
  value       = { for k, r in azurerm_dns_a_record.this : k => r.fqdn }
}

output "aaaa_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each AAAA record."
  value       = { for k, r in azurerm_dns_aaaa_record.this : k => r.fqdn }
}

output "cname_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each CNAME record."
  value       = { for k, r in azurerm_dns_cname_record.this : k => r.fqdn }
}

output "txt_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each TXT record."
  value       = { for k, r in azurerm_dns_txt_record.this : k => r.fqdn }
}

output "mx_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each MX record."
  value       = { for k, r in azurerm_dns_mx_record.this : k => r.fqdn }
}

output "ns_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each delegation NS record."
  value       = { for k, r in azurerm_dns_ns_record.this : k => r.fqdn }
}

output "caa_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each CAA record."
  value       = { for k, r in azurerm_dns_caa_record.this : k => r.fqdn }
}

output "srv_record_fqdns" {
  description = "Map of logical id => fully-qualified name for each SRV record."
  value       = { for k, r in azurerm_dns_srv_record.this : k => r.fqdn }
}
