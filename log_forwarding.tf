# =============================================================================
# Log Forwarding Profiles — Centralized logging configuration
# =============================================================================
# Defines where and how security logs are forwarded. Profiles can send to
# syslog, HTTP, email, or SNMP destinations. These profiles are referenced
# in security rules via the log_setting attribute.
#
# NOTE: The syslog/HTTP/email/SNMP server profiles referenced below must
# already exist in SCM. Create them manually or via separate Terraform
# resources before referencing here.
# =============================================================================

resource "scm_log_forwarding_profile" "security_logging" {
  folder      = var.folder
  name        = "LFP-Security-Logging"
  description = "Forward all security-relevant logs to SIEM"

  match_list = [
    {
      name        = "Forward-All-Threats"
      action_desc = "Forward threat logs for SOC analysis"
      log_type    = "threat"
      filter      = "All Logs"
    },
    {
      name        = "Forward-All-Traffic"
      action_desc = "Forward traffic logs for compliance and visibility"
      log_type    = "traffic"
      filter      = "All Logs"
    },
    {
      name        = "Forward-URL-Logs"
      action_desc = "Forward URL filtering logs for web visibility"
      log_type    = "url"
      filter      = "All Logs"
    },
    {
      name        = "Forward-WildFire-Logs"
      action_desc = "Forward WildFire analysis results"
      log_type    = "wildfire"
      filter      = "All Logs"
    },
    {
      name        = "Forward-DNS-Security"
      action_desc = "Forward DNS security events"
      log_type    = "dns-security"
      filter      = "All Logs"
    },
    {
      name        = "Forward-Data-Logs"
      action_desc = "Forward data filtering logs for DLP"
      log_type    = "data"
      filter      = "All Logs"
    },
  ]
}

resource "scm_log_forwarding_profile" "traffic_only" {
  folder      = var.folder
  name        = "LFP-Traffic-Only"
  description = "Forward traffic logs only (lightweight profile)"

  match_list = [
    {
      name     = "Forward-Traffic"
      log_type = "traffic"
      filter   = "All Logs"
    },
  ]
}
