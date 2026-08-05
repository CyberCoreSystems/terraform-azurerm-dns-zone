output "zone_id" {
  description = "Resource ID of the DNS zone."
  value       = module.dns.zone_id
}

output "name_servers" {
  description = "Name servers to set at your registrar to delegate the zone."
  value       = module.dns.name_servers
}

output "a_record_fqdns" {
  description = "Fully-qualified names of the A records created."
  value       = module.dns.a_record_fqdns
}
