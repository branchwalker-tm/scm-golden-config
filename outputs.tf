# =============================================================================
# Outputs — Key resource references
# =============================================================================

output "profile_group_strict_name" {
  description = "Name of the strict security profile group for use in rules"
  value       = scm_profile_group.strict.name
}

output "profile_group_standard_name" {
  description = "Name of the standard security profile group for use in rules"
  value       = scm_profile_group.standard.name
}

output "zone_names" {
  description = "Map of configured security zone names"
  value = {
    trust   = scm_zone.trust.name
    untrust = scm_zone.untrust.name
    dmz     = scm_zone.dmz.name
  }
}

output "zone_protection_profiles" {
  description = "Map of zone protection profile names"
  value = {
    best_practice = scm_zone_protection_profile.best_practice.name
    internal      = scm_zone_protection_profile.internal.name
  }
}

output "log_forwarding_profile_name" {
  description = "Primary log forwarding profile for security rules"
  value       = scm_log_forwarding_profile.security_logging.name
}

output "summary" {
  description = "Golden config deployment summary"
  value       = <<-EOT

    ╔══════════════════════════════════════════════════════════════════╗
    ║          VM-Series Golden Configuration — Deployed!             ║
    ╠══════════════════════════════════════════════════════════════════╣
    ║                                                                  ║
    ║  OBJECTS                                                         ║
    ║    Tags ................... 10                                    ║
    ║    Address Objects ........ 14                                    ║
    ║    Address Groups ......... 7  (3 static + 4 dynamic)            ║
    ║    Services ............... 10                                    ║
    ║    Service Groups ......... 4                                     ║
    ║                                                                  ║
    ║  SECURITY PROFILES                                               ║
    ║    Anti-Spyware ........... 2  (Strict + Standard)               ║
    ║    Vulnerability .......... 2  (Strict + Standard)               ║
    ║    DNS Security ........... 2  (Strict + Standard)               ║
    ║    File Blocking .......... 2  (Strict + Standard)               ║
    ║    Decryption ............. 1  (Best Practice)                    ║
    ║    Profile Groups ......... 2  (Strict + Standard)               ║
    ║                                                                  ║
    ║  NETWORK                                                         ║
    ║    Ethernet Interfaces .... 3  (Untrust, Trust, DMZ)             ║
    ║    Security Zones ......... 3  (Untrust, Trust, DMZ)             ║
    ║    Zone Protection ........ 2  (Best Practice + Internal)        ║
    ║                                                                  ║
    ║  POLICY                                                          ║
    ║    Security Rules ......... 13 (deny→infra→app→internet→deny)    ║
    ║    NAT Rules .............. 3  (2 SNAT + 1 DNAT)                 ║
    ║                                                                  ║
    ║  LOG FORWARDING                                                  ║
    ║    Profiles ............... 2  (Full + Traffic-Only)              ║
    ║                                                                  ║
    ╚══════════════════════════════════════════════════════════════════╝
  EOT
}
