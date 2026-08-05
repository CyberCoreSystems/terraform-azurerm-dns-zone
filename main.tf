# Azure public DNS zone (azurerm_dns_zone) plus a clean, map-driven set of
# record sets — A, AAAA, CNAME, TXT, MX, NS, CAA and SRV. Each record type maps
# to its own azurerm resource via for_each, so addressing is stable and changing
# one entry never churns the others.
#
# Notes on the model:
# - azurerm_dns_zone is always a PUBLIC zone (the world can query it). For
#   internal/split-horizon names use a private DNS zone instead — there is no
#   "encryption" knob for public DNS, the meaningful control is public vs private.
# - Record names are RELATIVE to the zone. Use "@" (the default) for the apex or
#   a label like "www"; do not pass a full FQDN.
# - TXT values are passed verbatim (no escaped quoting); Azure handles 255-char
#   segmentation for you. This differs from Route 53.

resource "azurerm_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "soa_record" {
    for_each = var.soa_record == null ? [] : [var.soa_record]
    content {
      email        = soa_record.value.email
      expire_time  = soa_record.value.expire_time
      minimum_ttl  = soa_record.value.minimum_ttl
      refresh_time = soa_record.value.refresh_time
      retry_time   = soa_record.value.retry_time
      ttl          = soa_record.value.ttl
      tags         = soa_record.value.tags
    }
  }
}

resource "azurerm_dns_a_record" "this" {
  for_each = var.a_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

resource "azurerm_dns_aaaa_record" "this" {
  for_each = var.aaaa_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

resource "azurerm_dns_cname_record" "this" {
  for_each = var.cname_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.record
  tags                = var.tags
}

resource "azurerm_dns_txt_record" "this" {
  for_each = var.txt_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.records
    content {
      value = record.value
    }
  }
}

resource "azurerm_dns_mx_record" "this" {
  for_each = var.mx_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.records
    content {
      preference = tostring(record.value.preference)
      exchange   = record.value.exchange
    }
  }
}

resource "azurerm_dns_ns_record" "this" {
  for_each = var.ns_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

resource "azurerm_dns_caa_record" "this" {
  for_each = var.caa_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.records
    content {
      flags = record.value.flags
      tag   = record.value.tag
      value = record.value.value
    }
  }
}

resource "azurerm_dns_srv_record" "this" {
  for_each = var.srv_records

  name                = each.value.name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.records
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}
