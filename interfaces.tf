# =============================================================================
# Ethernet Interfaces — VM-Series dataplane configuration
# =============================================================================
# IMPORTANT: Ethernet interfaces use template variables ($ethernet1_1, etc.)
# that require device-level variable mappings in SCM. They cannot be pushed
# from a shared folder without a target device.
#
# For AWS VM-Series deployments, interfaces are typically configured via
# bootstrap (init-cfg.txt / userdata) and are device-specific. Uncomment
# and use these resources only when targeting a specific device in SCM.
#
# resource "scm_ethernet_interface" "untrust" {
#   folder  = var.folder
#   name    = "$ethernet1_1"
#   comment = "Untrust interface - Internet facing"
#   layer3 = {
#     dhcp_client = {
#       enable               = true
#       create_default_route = true
#       default_route_metric = 10
#     }
#     mtu = 1500
#   }
#   link_speed  = "auto"
#   link_duplex = "auto"
#   link_state  = "auto"
# }
#
# resource "scm_ethernet_interface" "trust" {
#   folder  = var.folder
#   name    = "$ethernet1_2"
#   comment = "Trust interface - Internal/private workloads"
#   layer3 = {
#     dhcp_client = {
#       enable               = true
#       create_default_route = false
#     }
#     mtu = 1500
#   }
#   link_speed  = "auto"
#   link_duplex = "auto"
#   link_state  = "auto"
# }
#
# resource "scm_ethernet_interface" "dmz" {
#   folder  = var.folder
#   name    = "$ethernet1_3"
#   comment = "DMZ interface - Web tier / ALB targets"
#   layer3 = {
#     dhcp_client = {
#       enable               = true
#       create_default_route = false
#     }
#     mtu = 1500
#   }
#   link_speed  = "auto"
#   link_duplex = "auto"
#   link_state  = "auto"
# }
