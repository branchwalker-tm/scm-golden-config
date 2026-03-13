# =============================================================================
# Palo Alto Networks VM-Series Golden Configuration
# Deployed via Strata Cloud Manager (SCM) Terraform Provider
# =============================================================================
# This project demonstrates a comprehensive "golden config" for a
# Palo Alto Networks VM-Series firewall in AWS, showcasing:
#
#   - Address Objects & Groups (static + dynamic)
#   - Service Objects & Groups
#   - Security Profiles (Anti-Spyware, Vulnerability, DNS Security,
#     File Blocking, URL Filtering)
#   - Security Profile Groups
#   - Log Forwarding Profiles
#   - Decryption Profiles
#   - Zone Protection Profiles
#   - Security Zones & Ethernet Interfaces
#   - Security Policy (layered best-practice rulebase)
#   - NAT Policy (outbound source NAT + inbound DNAT)
#
# Authentication is handled via environment variables:
#   export SCM_CLIENT_ID="<your-client-id>"
#   export SCM_CLIENT_SECRET="<your-client-secret>"
#   export SCM_TSG_ID="<your-tsg-id>"
#   export SCM_SCOPE="tsg_id:<your-tsg-id>"
# =============================================================================

terraform {
  required_version = ">= 1.4.6"

  required_providers {
    scm = {
      source  = "PaloAltoNetworks/scm"
      version = ">= 1.0.8"
    }
  }
}

provider "scm" {}
