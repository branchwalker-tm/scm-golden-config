# =============================================================================
# NAT Policy — Network Address Translation rules
# =============================================================================
# Covers two primary NAT patterns for a VM-Series in AWS:
#
#   1. Outbound Source NAT — internal hosts masquerade behind the untrust
#      IP when accessing the internet (uses a dedicated NAT address object)
#   2. Inbound Destination NAT — external traffic is translated to internal
#      DMZ web server addresses
# =============================================================================


# =========================================================================
# Outbound Source NAT (hide-NAT / PAT)
# =========================================================================

resource "scm_nat_rule" "outbound_snat_trust" {
  folder   = var.folder
  name     = "SNAT-Trust-to-Internet"
  position = "pre"

  from        = ["Trust"]
  to          = ["Untrust"]
  source      = [scm_address.trusted_network.name]
  destination = ["any"]
  service     = "any"

  nat_type = "ipv4"

  source_translation = {
    dynamic_ip_and_port = {
      translated_address = [scm_address.nat_egress_ip.name]
    }
  }

  description = "Hide-NAT: Trust hosts behind untrust interface IP"
}

resource "scm_nat_rule" "outbound_snat_dmz" {
  folder   = var.folder
  name     = "SNAT-DMZ-to-Internet"
  position = "pre"

  from        = ["DMZ"]
  to          = ["Untrust"]
  source      = [scm_address.dmz_network.name]
  destination = ["any"]
  service     = "any"

  nat_type = "ipv4"

  source_translation = {
    dynamic_ip_and_port = {
      translated_address = [scm_address.nat_egress_ip.name]
    }
  }

  description = "Hide-NAT: DMZ hosts behind untrust interface IP"
}


# =========================================================================
# Inbound Destination NAT (static / port-forward)
# =========================================================================

resource "scm_nat_rule" "inbound_dnat_web" {
  folder   = var.folder
  name     = "DNAT-Inbound-HTTPS-to-WebServer"
  position = "pre"

  from        = ["Untrust"]
  to          = ["Untrust"]
  source      = ["any"]
  destination = [scm_address.public_vip.name]
  service     = "service-https"

  nat_type = "ipv4"

  destination_translation = {
    translated_address = scm_address.web_server_1.name
    translated_port    = 443
  }

  description = "DNAT: Inbound HTTPS to primary web server"
}
