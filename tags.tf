# =============================================================================
# Tags — Organizational taxonomy for all firewall objects
# =============================================================================
# Tags provide a consistent labeling system across address objects, rules,
# and groups. They enable dynamic address groups and simplify auditing.

# --- Environment Tags ---
resource "scm_tag" "environment_production" {
  folder   = var.folder
  name     = "Environment-Production"
  color    = "Red"
  comments = "Production workloads - strict security posture"
}

resource "scm_tag" "environment_staging" {
  folder   = var.folder
  name     = "Environment-Staging"
  color    = "Orange"
  comments = "Staging/pre-production workloads"
}

resource "scm_tag" "environment_development" {
  folder   = var.folder
  name     = "Environment-Development"
  color    = "Blue"
  comments = "Development workloads - relaxed posture"
}

# --- Application Tier Tags ---
resource "scm_tag" "tier_web" {
  folder   = var.folder
  name     = "Tier-Web"
  color    = "Cyan"
  comments = "Web/frontend tier (DMZ-facing)"
}

resource "scm_tag" "tier_app" {
  folder   = var.folder
  name     = "Tier-App"
  color    = "Green"
  comments = "Application/middleware tier"
}

resource "scm_tag" "tier_db" {
  folder   = var.folder
  name     = "Tier-Database"
  color    = "Brown"
  comments = "Database tier - most restricted"
}

# --- Compliance Tags ---
resource "scm_tag" "compliance_pci" {
  folder   = var.folder
  name     = "Compliance-PCI"
  color    = "Maroon"
  comments = "PCI-DSS scope - cardholder data environment"
}

resource "scm_tag" "compliance_hipaa" {
  folder   = var.folder
  name     = "Compliance-HIPAA"
  color    = "Olive"
  comments = "HIPAA scope - ePHI handling systems"
}

# --- Security Classification Tags ---
resource "scm_tag" "sanctioned_saas" {
  folder   = var.folder
  name     = "Sanctioned-SaaS"
  color    = "Green"
  comments = "Approved SaaS applications"
}

resource "scm_tag" "managed_by_terraform" {
  folder   = var.folder
  name     = "Managed-By-Terraform"
  color    = "Lime"
  comments = "Object lifecycle managed by Terraform/IaC"
}
