variable "zone_name" {
  description = "Public DNS zone name (the domain you delegate to Azure), e.g. \"example.com\". A trailing dot is optional. azurerm_dns_zone is a PUBLIC zone — for split-horizon/internal names use a private DNS zone instead."
  type        = string

  validation {
    condition     = can(regex("^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", var.zone_name))
    error_message = "zone_name must be a valid DNS name with at least two labels (e.g. example.com); a single trailing dot is allowed."
  }
}

variable "resource_group_name" {
  description = "Name of an EXISTING resource group that will hold the zone and its record sets (this module does not create the resource group). DNS zones are global, so no location is required."
  type        = string

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "resource_group_name must be 1-90 characters."
  }
}

# ---------------------------------------------------------------------------
# SOA record (optional). Leave null to keep Azure's default SOA. The contact
# email uses dot notation (hostmaster.example.com), not an @ sign.
# ---------------------------------------------------------------------------

variable "soa_record" {
  description = "Optional override of the zone's auto-created SOA record. email is required when set and uses dot notation (e.g. \"hostmaster.example.com\"). Leave null to keep Azure's defaults."
  type = object({
    email        = string
    expire_time  = optional(number, 2419200)
    minimum_ttl  = optional(number, 300)
    refresh_time = optional(number, 3600)
    retry_time   = optional(number, 300)
    ttl          = optional(number, 3600)
    tags         = optional(map(string), {})
  })
  default = null

  validation {
    condition     = var.soa_record == null ? true : can(regex("^[^@\\s]+$", var.soa_record.email))
    error_message = "soa_record.email must use dot notation without an @ sign (e.g. hostmaster.example.com)."
  }
}

# ---------------------------------------------------------------------------
# Records (map-driven, one map per type). The map key is a stable logical id
# you choose; it never affects the DNS name. Set name = "@" for the zone apex
# (the default), or a relative label like "www" (NOT a full FQDN — Azure record
# names are relative to the zone).
# ---------------------------------------------------------------------------

variable "a_records" {
  description = "A records (IPv4) keyed by a stable logical id. Each: { name = \"www\"|\"@\", ttl, records = [\"203.0.113.10\", ...] }."
  type = map(object({
    name    = optional(string, "@")
    ttl     = optional(number, 3600)
    records = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.a_records) : length(r.records) > 0])
    error_message = "Each a_records entry must list at least one IPv4 address in records."
  }
  validation {
    condition     = alltrue([for r in values(var.a_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "a_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "aaaa_records" {
  description = "AAAA records (IPv6) keyed by a stable logical id. Each: { name, ttl, records = [\"2001:db8::1\", ...] }."
  type = map(object({
    name    = optional(string, "@")
    ttl     = optional(number, 3600)
    records = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.aaaa_records) : length(r.records) > 0])
    error_message = "Each aaaa_records entry must list at least one IPv6 address in records."
  }
  validation {
    condition     = alltrue([for r in values(var.aaaa_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "aaaa_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "cname_records" {
  description = "CNAME records keyed by a stable logical id. Each: { name = \"www\", ttl, record = \"target.example.com\" }. A CNAME cannot live at the apex (use an A record / alias there)."
  type = map(object({
    name   = optional(string, "@")
    ttl    = optional(number, 3600)
    record = string
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.cname_records) : r.name != "@" && r.name != ""])
    error_message = "cname_records cannot target the zone apex (name \"@\"/empty) — DNS forbids a CNAME at the apex."
  }
  validation {
    condition     = alltrue([for r in values(var.cname_records) : length(r.record) > 0])
    error_message = "Each cname_records entry must set a non-empty record (the canonical target name)."
  }
  validation {
    condition     = alltrue([for r in values(var.cname_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "cname_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "txt_records" {
  description = "TXT records keyed by a stable logical id. Each: { name = \"@\", ttl, records = [\"v=spf1 -all\", ...] }. Each string becomes a separate TXT value — do NOT wrap in escaped quotes (Azure handles 255-char segmentation)."
  type = map(object({
    name    = optional(string, "@")
    ttl     = optional(number, 3600)
    records = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.txt_records) : length(r.records) > 0])
    error_message = "Each txt_records entry must list at least one string value in records."
  }
  validation {
    condition     = alltrue([for r in values(var.txt_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "txt_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "mx_records" {
  description = "MX records keyed by a stable logical id. Each: { name = \"@\", ttl, records = [{ preference = 10, exchange = \"mail.example.com\" }, ...] }."
  type = map(object({
    name = optional(string, "@")
    ttl  = optional(number, 3600)
    records = list(object({
      preference = number
      exchange   = string
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.mx_records) : length(r.records) > 0])
    error_message = "Each mx_records entry must list at least one { preference, exchange } pair."
  }
  validation {
    condition     = alltrue([for r in values(var.mx_records) : alltrue([for m in r.records : m.preference >= 0 && m.preference <= 65535])])
    error_message = "mx_records preference must be between 0 and 65535."
  }
  validation {
    condition     = alltrue([for r in values(var.mx_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "mx_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "ns_records" {
  description = "NS records for DELEGATING a subdomain, keyed by a stable logical id. Each: { name = \"sub\", ttl, records = [\"ns1.example.net\", ...] }. The apex NS set is managed by Azure and cannot be overridden here."
  type = map(object({
    name    = optional(string, "@")
    ttl     = optional(number, 3600)
    records = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.ns_records) : r.name != "@" && r.name != ""])
    error_message = "ns_records cannot target the apex — Azure manages the zone's own NS set. Use a sub-label to delegate a subdomain."
  }
  validation {
    condition     = alltrue([for r in values(var.ns_records) : length(r.records) > 0])
    error_message = "Each ns_records entry must list at least one name server in records."
  }
  validation {
    condition     = alltrue([for r in values(var.ns_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "ns_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "caa_records" {
  description = "CAA records keyed by a stable logical id. Each: { name = \"@\", ttl, records = [{ flags = 0, tag = \"issue\", value = \"letsencrypt.org\" }, ...] }."
  type = map(object({
    name = optional(string, "@")
    ttl  = optional(number, 3600)
    records = list(object({
      flags = number
      tag   = string
      value = string
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.caa_records) : length(r.records) > 0])
    error_message = "Each caa_records entry must list at least one { flags, tag, value } record."
  }
  validation {
    condition     = alltrue([for r in values(var.caa_records) : alltrue([for c in r.records : contains(["issue", "issuewild", "iodef"], c.tag)])])
    error_message = "caa_records tag must be one of issue, issuewild or iodef."
  }
  validation {
    condition     = alltrue([for r in values(var.caa_records) : alltrue([for c in r.records : c.flags >= 0 && c.flags <= 255])])
    error_message = "caa_records flags must be between 0 and 255."
  }
  validation {
    condition     = alltrue([for r in values(var.caa_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "caa_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "srv_records" {
  description = "SRV records keyed by a stable logical id. The key/name is typically \"_service._proto\" (e.g. \"_sip._tls\"). Each: { name, ttl, records = [{ priority, weight, port, target }, ...] }."
  type = map(object({
    name = string
    ttl  = optional(number, 3600)
    records = list(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.srv_records) : length(r.records) > 0])
    error_message = "Each srv_records entry must list at least one { priority, weight, port, target } record."
  }
  validation {
    condition     = alltrue([for r in values(var.srv_records) : alltrue([for s in r.records : s.port >= 0 && s.port <= 65535])])
    error_message = "srv_records port must be between 0 and 65535."
  }
  validation {
    condition     = alltrue([for r in values(var.srv_records) : r.ttl >= 1 && r.ttl <= 2147483647])
    error_message = "srv_records ttl must be between 1 and 2147483647 seconds."
  }
}

variable "tags" {
  description = "Tags applied to the zone and every record set."
  type        = map(string)
  default     = {}
}
