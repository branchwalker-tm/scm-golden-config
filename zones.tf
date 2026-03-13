# =============================================================================
# Security Zones — Traffic segmentation boundaries
# =============================================================================
# Zones define trust boundaries on the firewall. Every interface must belong
# to a zone, and security policy is evaluated between zones (from → to).
#
# For a VM-Series in AWS, a typical topology is:
#   - Trust zone    (eth1/2) → internal/private subnets
#   - Untrust zone  (eth1/1) → internet-facing / public subnets
#   - DMZ zone      (eth1/3) → application load balancer / web tier
#
# NOTE: Interface names (e.g., "ethernet1/1") must match the actual VM-Series
# interface mappings in your AWS deployment. Adjust interface references below
# to match your ENI-to-dataplane mapping.
# =============================================================================

resource "scm_zone" "untrust" {
  folder = var.folder
  name   = "Untrust"
  network = {
    layer3                          = []
    zone_protection_profile         = scm_zone_protection_profile.best_practice.name
    enable_packet_buffer_protection = true
  }
  enable_user_identification   = false
  enable_device_identification = false
}

resource "scm_zone" "trust" {
  folder = var.folder
  name   = "Trust"
  network = {
    layer3                          = []
    zone_protection_profile         = scm_zone_protection_profile.internal.name
    enable_packet_buffer_protection = true
  }
  enable_user_identification   = true
  enable_device_identification = true
}

resource "scm_zone" "dmz" {
  folder = var.folder
  name   = "DMZ"
  network = {
    layer3                          = []
    zone_protection_profile         = scm_zone_protection_profile.best_practice.name
    enable_packet_buffer_protection = true
  }
  enable_user_identification   = false
  enable_device_identification = false
}
