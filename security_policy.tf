# =============================================================================
# Security Policy — Layered best-practice rulebase
# =============================================================================
# The rulebase follows a structured approach:
#
#   1. Explicit deny rules (block known-bad first)
#   2. Infrastructure allow rules (DNS, NTP, logging)
#   3. Application-specific allow rules (web, app, DB tiers)
#   4. Outbound internet rules (with full threat inspection)
#   5. Default deny-all (implicit, but we make it explicit for logging)
#
# Each rule references the appropriate Security Profile Group for
# inline threat prevention and specifies log forwarding.
# =============================================================================

# --- Rule position is based on the order of resource declaration ---
# --- The 'position' attribute controls rulebase ordering          ---

# =========================================================================
# SECTION 1: Block Known-Bad Traffic
# =========================================================================

resource "scm_security_rule" "block_inbound_rfc1918" {
  folder   = var.folder
  name     = "Block-Inbound-RFC1918-Spoofed"
  position = "pre"

  from        = ["Untrust"]
  to          = ["any"]
  source      = [scm_address_group.rfc1918_all.name]
  destination = ["any"]
  application = ["any"]
  service     = ["any"]
  source_user = ["any"]
  category    = ["any"]
  action      = "deny"

  log_end = true

  description = "Block inbound traffic from spoofed RFC1918 sources"
}

resource "scm_security_rule" "block_quic" {
  folder   = var.folder
  name     = "Block-QUIC-Protocol"
  position = "pre"

  from        = ["any"]
  to          = ["any"]
  source      = ["any"]
  destination = ["any"]
  application = ["quic"]
  service     = ["any"]
  source_user = ["any"]
  category    = ["any"]
  action      = "deny"

  log_end = true

  description = "Force QUIC fallback to HTTPS for full TLS inspection"
}


# =========================================================================
# SECTION 2: Infrastructure Services (DNS, NTP, Logging)
# =========================================================================

resource "scm_security_rule" "allow_dns_outbound" {
  folder   = var.folder
  name     = "Allow-DNS-Outbound"
  position = "pre"

  from        = ["Trust", "DMZ"]
  to          = ["Untrust"]
  source      = [scm_address_group.dns_servers.name]
  destination = ["any"]
  application = ["dns"]
  service     = ["application-default"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  profile_setting = {
    group = [scm_profile_group.strict.name]
  }

  description = "Allow DNS servers to resolve external queries"
}

resource "scm_security_rule" "allow_dns_internal" {
  folder   = var.folder
  name     = "Allow-DNS-Internal"
  position = "pre"

  from        = ["Trust"]
  to          = ["Trust"]
  source      = ["any"]
  destination = [scm_address_group.dns_servers.name]
  application = ["dns"]
  service     = ["application-default"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  description = "Allow internal hosts to reach DNS servers"
}

resource "scm_security_rule" "allow_ntp" {
  folder   = var.folder
  name     = "Allow-NTP"
  position = "pre"

  from        = ["Trust", "DMZ"]
  to          = ["Untrust"]
  source      = ["any"]
  destination = ["any"]
  application = ["ntp"]
  service     = ["application-default"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  description = "Allow NTP time synchronization"
}


# =========================================================================
# SECTION 3: Application Tier Rules (Web → App → DB)
# =========================================================================

resource "scm_security_rule" "allow_untrust_to_dmz_web" {
  folder   = var.folder
  name     = "Allow-Untrust-to-DMZ-Web"
  position = "pre"

  from        = ["Untrust"]
  to          = ["DMZ"]
  source      = ["any"]
  destination = [scm_address_group.web_servers.name]
  application = ["web-browsing", "ssl"]
  service     = ["application-default"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_start = false
  log_end   = true

  profile_setting = {
    group = [scm_profile_group.strict.name]
  }

  description = "Allow inbound HTTPS to DMZ web servers"
}

resource "scm_security_rule" "allow_dmz_to_trust_app" {
  folder   = var.folder
  name     = "Allow-DMZ-to-Trust-App"
  position = "pre"

  from        = ["DMZ"]
  to          = ["Trust"]
  source      = [scm_address_group.web_servers.name]
  destination = [scm_address.app_server_1.name]
  application = ["web-browsing", "ssl"]
  service     = [scm_service_group.sg_web_services.name]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  profile_setting = {
    group = [scm_profile_group.strict.name]
  }

  description = "Allow web tier to reach application tier"
}

resource "scm_security_rule" "allow_app_to_db" {
  folder   = var.folder
  name     = "Allow-App-to-DB"
  position = "pre"

  from        = ["Trust"]
  to          = ["Trust"]
  source      = [scm_address.app_server_1.name]
  destination = [scm_address_group.production_databases.name]
  application = ["any"]
  service     = [scm_service_group.sg_database_services.name]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  profile_setting = {
    group = [scm_profile_group.strict.name]
  }

  description = "Allow application tier to reach database tier (PCI scope)"
}


# =========================================================================
# SECTION 4: Outbound Internet Access
# =========================================================================

resource "scm_security_rule" "allow_trust_to_internet" {
  folder   = var.folder
  name     = "Allow-Trust-Internet-Browsing"
  position = "pre"

  from        = ["Trust"]
  to          = ["Untrust"]
  source      = [scm_address.trusted_network.name]
  destination = ["any"]
  application = ["web-browsing", "ssl", "dns"]
  service     = ["application-default"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  profile_setting = {
    group = [scm_profile_group.standard.name]
  }

  description = "Allow trusted users outbound web/SSL with standard threat inspection"
}

resource "scm_security_rule" "allow_saas_apps" {
  folder   = var.folder
  name     = "Allow-Sanctioned-SaaS"
  position = "pre"

  from        = ["Trust"]
  to          = ["Untrust"]
  source      = [scm_address.trusted_network.name]
  destination = ["any"]
  application = [
    "ms-office365",
    "github",
    "slack",
    "zoom",
    "amazon-aws-console",
    "salesforce",
  ]
  service     = ["application-default"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  profile_setting = {
    group = [scm_profile_group.standard.name]
  }

  description = "Allow sanctioned SaaS applications with threat inspection"
}

resource "scm_security_rule" "allow_software_updates" {
  folder   = var.folder
  name     = "Allow-Software-Updates"
  position = "pre"

  from        = ["Trust", "DMZ"]
  to          = ["Untrust"]
  source      = ["any"]
  destination = ["any"]
  application = [
    "apt-get",
    "yum",
    "ssl",
    "web-browsing",
  ]
  service     = ["application-default"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  profile_setting = {
    group = [scm_profile_group.standard.name]
  }

  description = "Allow OS and package updates"
}

resource "scm_security_rule" "allow_aws_metadata" {
  folder   = var.folder
  name     = "Allow-AWS-Instance-Metadata"
  position = "pre"

  from        = ["Trust", "DMZ"]
  to          = ["Untrust"]
  source      = [scm_address.aws_vpc.name]
  destination = [scm_address.fqdn_aws_metadata.name]
  application = ["any"]
  service     = ["any"]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  description = "Allow EC2 instances to reach AWS metadata service (IMDS)"
}


# =========================================================================
# SECTION 5: Monitoring & Management
# =========================================================================

resource "scm_security_rule" "allow_logging_infra" {
  folder   = var.folder
  name     = "Allow-Logging-Infrastructure"
  position = "pre"

  from        = ["Trust", "DMZ"]
  to          = ["Trust"]
  source      = ["any"]
  destination = ["any"]
  application = ["syslog", "snmp"]
  service     = [scm_service_group.sg_logging_services.name]
  source_user = ["any"]
  category    = ["any"]
  action      = "allow"

  log_end = true

  description = "Allow all hosts to send logs and SNMP traps"
}


# =========================================================================
# SECTION 6: Explicit Deny-All (catch-all with logging)
# =========================================================================

resource "scm_security_rule" "deny_all" {
  folder   = var.folder
  name     = "Deny-All-Default"
  position = "pre"

  from        = ["any"]
  to          = ["any"]
  source      = ["any"]
  destination = ["any"]
  application = ["any"]
  service     = ["any"]
  source_user = ["any"]
  category    = ["any"]
  action      = "deny"

  log_end = true

  description = "Explicit deny-all with logging - catches any traffic not matched above"
}
