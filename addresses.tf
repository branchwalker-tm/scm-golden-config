# =============================================================================
# Address Objects — Network identity building blocks
# =============================================================================
# Demonstrates all four address types: ip_netmask, ip_range, fqdn, ip_wildcard

# --- Internal Network Addresses ---
resource "scm_address" "trusted_network" {
  folder      = var.folder
  name        = "Trusted-Network"
  description = "Internal trusted network"
  ip_netmask  = var.trusted_network
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

resource "scm_address" "dmz_network" {
  folder      = var.folder
  name        = "DMZ-Network"
  description = "DMZ network segment"
  ip_netmask  = var.dmz_network
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

resource "scm_address" "aws_vpc" {
  folder      = var.folder
  name        = "AWS-VPC-CIDR"
  description = "AWS VPC containing VM-Series deployment"
  ip_netmask  = var.aws_vpc_cidr
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

# --- Server Addresses ---
resource "scm_address" "web_server_1" {
  folder      = var.folder
  name        = "Web-Server-01"
  description = "Primary web server"
  ip_netmask  = "10.100.10.10/32"
  tag         = [scm_tag.tier_web.name, scm_tag.environment_production.name]
  depends_on  = [scm_tag.tier_web, scm_tag.environment_production]
}

resource "scm_address" "web_server_2" {
  folder      = var.folder
  name        = "Web-Server-02"
  description = "Secondary web server"
  ip_netmask  = "10.100.10.11/32"
  tag         = [scm_tag.tier_web.name, scm_tag.environment_production.name]
  depends_on  = [scm_tag.tier_web, scm_tag.environment_production]
}

resource "scm_address" "app_server_1" {
  folder      = var.folder
  name        = "App-Server-01"
  description = "Primary application server"
  ip_netmask  = "10.100.20.10/32"
  tag         = [scm_tag.tier_app.name, scm_tag.environment_production.name]
  depends_on  = [scm_tag.tier_app, scm_tag.environment_production]
}

resource "scm_address" "db_server_1" {
  folder      = var.folder
  name        = "DB-Server-01"
  description = "Primary database server"
  ip_netmask  = "10.100.30.10/32"
  tag = [
    scm_tag.tier_db.name,
    scm_tag.environment_production.name,
    scm_tag.compliance_pci.name
  ]
  depends_on = [scm_tag.tier_db, scm_tag.environment_production, scm_tag.compliance_pci]
}

resource "scm_address" "dns_server_primary" {
  folder      = var.folder
  name        = "DNS-Server-Primary"
  description = "Primary internal DNS server"
  ip_netmask  = "${var.dns_servers[0]}/32"
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

resource "scm_address" "dns_server_secondary" {
  folder      = var.folder
  name        = "DNS-Server-Secondary"
  description = "Secondary internal DNS server"
  ip_netmask  = "${var.dns_servers[1]}/32"
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

# --- IP Range Example ---
resource "scm_address" "dhcp_scope" {
  folder      = var.folder
  name        = "DHCP-User-Scope"
  description = "DHCP range for end-user workstations"
  ip_range    = "10.100.50.100-10.100.50.250"
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

# --- FQDN Examples (external services) ---
resource "scm_address" "fqdn_microsoft_updates" {
  folder      = var.folder
  name        = "FQDN-Microsoft-Updates"
  description = "Microsoft update services"
  fqdn        = "update.microsoft.com"
  tag         = [scm_tag.sanctioned_saas.name]
  depends_on  = [scm_tag.sanctioned_saas]
}

resource "scm_address" "fqdn_aws_metadata" {
  folder      = var.folder
  name        = "FQDN-AWS-Metadata"
  description = "AWS instance metadata endpoint"
  ip_netmask  = "169.254.169.254/32"
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

# --- Wildcard Example ---
resource "scm_address" "wildcard_class_c" {
  folder      = var.folder
  name        = "Wildcard-Monitoring-Subnet"
  description = "Monitoring agents across /24 subnets"
  ip_wildcard = "10.100.0.1/0.0.255.0"
  # NOTE: ip_wildcard type does not support tags in SCM
}

# --- NAT Egress Address ---
resource "scm_address" "nat_egress_ip" {
  folder      = var.folder
  name        = "NAT-Egress-IP"
  description = "Untrust interface IP used for outbound source NAT - update to match your VM-Series"
  ip_netmask  = var.nat_egress_ip
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

resource "scm_address" "public_vip" {
  folder      = var.folder
  name        = "Public-VIP"
  description = "Public-facing VIP/EIP for inbound DNAT - update to match your AWS EIP"
  ip_netmask  = var.public_vip
  tag         = [scm_tag.managed_by_terraform.name]
  depends_on  = [scm_tag.managed_by_terraform]
}

# --- RFC 1918 and Bogon Addresses ---
resource "scm_address" "rfc1918_10" {
  folder      = var.folder
  name        = "RFC1918-10"
  description = "RFC 1918 - 10.0.0.0/8"
  ip_netmask  = "10.0.0.0/8"
}

resource "scm_address" "rfc1918_172" {
  folder      = var.folder
  name        = "RFC1918-172"
  description = "RFC 1918 - 172.16.0.0/12"
  ip_netmask  = "172.16.0.0/12"
}

resource "scm_address" "rfc1918_192" {
  folder      = var.folder
  name        = "RFC1918-192"
  description = "RFC 1918 - 192.168.0.0/16"
  ip_netmask  = "192.168.0.0/16"
}


# =============================================================================
# Address Groups — Static and Dynamic groupings
# =============================================================================

# --- Static Groups ---
resource "scm_address_group" "web_servers" {
  folder      = var.folder
  name        = "AG-Web-Servers"
  description = "All web/frontend servers"
  static = [
    scm_address.web_server_1.name,
    scm_address.web_server_2.name,
  ]
}

resource "scm_address_group" "dns_servers" {
  folder      = var.folder
  name        = "AG-DNS-Servers"
  description = "Internal DNS servers"
  static = [
    scm_address.dns_server_primary.name,
    scm_address.dns_server_secondary.name,
  ]
}

resource "scm_address_group" "rfc1918_all" {
  folder      = var.folder
  name        = "AG-RFC1918-All"
  description = "All RFC 1918 private address space"
  static = [
    scm_address.rfc1918_10.name,
    scm_address.rfc1918_172.name,
    scm_address.rfc1918_192.name,
  ]
}

# --- Dynamic Groups (tag-based membership) ---
resource "scm_address_group" "production_servers" {
  folder      = var.folder
  name        = "AG-Production-All"
  description = "Dynamic group: all production-tagged servers"
  dynamic = {
    filter = "'Environment-Production'"
  }
}

resource "scm_address_group" "pci_scope" {
  folder      = var.folder
  name        = "AG-PCI-Scope"
  description = "Dynamic group: all PCI-scoped systems"
  dynamic = {
    filter = "'Compliance-PCI'"
  }
}

resource "scm_address_group" "production_web" {
  folder      = var.folder
  name        = "AG-Production-Web"
  description = "Dynamic group: production web tier"
  dynamic = {
    filter = "'Tier-Web' and 'Environment-Production'"
  }
}

resource "scm_address_group" "production_databases" {
  folder      = var.folder
  name        = "AG-Production-Databases"
  description = "Dynamic group: production database tier"
  dynamic = {
    filter = "'Tier-Database' and 'Environment-Production'"
  }
}
