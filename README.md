# Azure Public DNS Zone & Records

An Azure public DNS zone plus a map-driven set of record sets - A, AAAA, CNAME, TXT, MX, NS, CAA and SRV - with relative naming, verbatim TXT values, and apex footgun guards.

This module was **applied to a real Azure account, verified, and destroyed** on 2026-06-30 — not just `terraform validate`d.

## Usage

```hcl
module "dns_zone" {
  source  = "registry.terraform.io/CyberCoreSystems/dns-zone/azurerm"
  version = "~> 1.0"

  # See variables.tf for the full input contract.
}
```

## Why this module

Every module we publish goes through the same gate before release:

| check | what it means |
|---|---|
| `tofu validate` + `tflint` | it parses and lints clean |
| `checkov` | scanned for insecure defaults |
| **live test** | **really applied to a cloud account, outputs verified, then destroyed** |

That last row is the one most module catalogues skip. A module that has never
been applied has never been proven.

## Provider compatibility

```
azurerm >= 4.0, < 5.0
```

## More modules

This is one of **183 verified Terraform modules across 19 cloud platforms** —
AWS, Azure, GCP, Oracle OCI, Cloudflare, Akamai, DigitalOcean, Linode, Hetzner,
Vultr, Scaleway, Alibaba, IBM, UpCloud, Civo, Exoscale, OVH, Tencent and Huawei.

Browse the full catalogue at **[www.iac-bazaar.com](https://www.iac-bazaar.com)**, including
production landing zones for AWS, Azure and GCP that have each been live-tested
as a single composed apply.

- Module page: [https://www.iac-bazaar.com/catalog/azure-dns-zone](https://www.iac-bazaar.com/catalog/azure-dns-zone)
- How verification works: [https://www.iac-bazaar.com/verified](https://www.iac-bazaar.com/verified)

## Licence

See [LICENSE](./LICENSE).
