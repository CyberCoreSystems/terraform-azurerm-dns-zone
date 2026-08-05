provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Minimal runnable example: a public DNS zone with a www A record, an apex SPF
# TXT record and a CAA record, all wired through the module's map-driven inputs.
module "dns" {
  source = "../.."

  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name

  a_records = {
    www = {
      name    = "www"
      ttl     = 300
      records = ["192.0.2.10"] # TEST-NET-1 documentation address
    }
  }

  txt_records = {
    spf = {
      name    = "@"
      ttl     = 300
      records = ["v=spf1 -all"] # no escaped quotes — Azure segments for you
    }
  }

  caa_records = {
    issue = {
      name = "@"
      ttl  = 3600
      records = [
        { flags = 0, tag = "issue", value = "letsencrypt.org" },
      ]
    }
  }

  tags = {
    Environment = "example"
    ManagedBy   = "iac-bazaar"
  }
}
