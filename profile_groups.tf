# =============================================================================
# Security Profile Groups — Bundled threat prevention stacks
# =============================================================================
# Profile groups tie together individual security profiles into a single
# reference that can be applied to security rules. This simplifies rule
# management and ensures consistent protection across the rulebase.
#
# NOTE: "virus_and_wildfire_analysis" references a profile that must be
# created manually in SCM (the API does not support AV/WildFire profile
# creation). The default "best-practice" profile ships with every NGFW.
# Adjust the name below to match your environment.
# =============================================================================

resource "scm_profile_group" "strict" {
  folder = var.folder
  name   = "Profile-Group-Strict"

  spyware                    = [scm_anti_spyware_profile.strict.name]
  vulnerability              = [scm_vulnerability_protection_profile.strict.name]
  dns_security               = [scm_dns_security_profile.strict.name]
  file_blocking              = [scm_file_blocking_profile.strict.name]
  virus_and_wildfire_analysis = ["best-practice"]
}

resource "scm_profile_group" "standard" {
  folder = var.folder
  name   = "Profile-Group-Standard"

  spyware                    = [scm_anti_spyware_profile.standard.name]
  vulnerability              = [scm_vulnerability_protection_profile.standard.name]
  dns_security               = [scm_dns_security_profile.standard.name]
  file_blocking              = [scm_file_blocking_profile.standard.name]
  virus_and_wildfire_analysis = ["best-practice"]
}
