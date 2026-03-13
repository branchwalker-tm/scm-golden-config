# =============================================================================
# Security Profiles — Threat prevention stack
# =============================================================================
# Best-practice security profiles aligned with Palo Alto Networks
# recommendations. Two tiers are defined:
#
#   STRICT  — Production / PCI / high-value workloads (block + reset)
#   STANDARD — General traffic (alert on low, block on critical/high)
#
# NOTE: Antivirus/WildFire profiles cannot be fully managed via the SCM API
# at this time. Create them manually in SCM and reference by name in the
# Security Profile Group below.
# =============================================================================


# -----------------------------------------------------------------------------
# Anti-Spyware Profiles
# -----------------------------------------------------------------------------

resource "scm_anti_spyware_profile" "strict" {
  folder                = var.folder
  name                  = "Anti-Spyware-Strict"
  description           = "Strict anti-spyware: drop critical/high, reset medium, alert low"
  cloud_inline_analysis = true

  rules = [
    {
      name     = "Block-Critical-Severity"
      severity = ["critical"]
      category = "any"
      action = {
        reset_both = {}
      }
      packet_capture = "single-packet"
      threat_name    = "any"
    },
    {
      name     = "Block-High-Severity"
      severity = ["high"]
      category = "any"
      action = {
        reset_both = {}
      }
      packet_capture = "single-packet"
      threat_name    = "any"
    },
    {
      name     = "Block-Medium-Severity"
      severity = ["medium"]
      category = "any"
      action = {
        drop = {}
      }
      packet_capture = "single-packet"
      threat_name    = "any"
    },
    {
      name     = "Alert-Low-Severity"
      severity = ["low"]
      category = "any"
      action = {
        alert = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
    },
    {
      name     = "Alert-Informational"
      severity = ["informational"]
      category = "any"
      action = {
        allow = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
    },
  ]
}

resource "scm_anti_spyware_profile" "standard" {
  folder                = var.folder
  name                  = "Anti-Spyware-Standard"
  description           = "Standard anti-spyware: drop critical/high, alert medium/low"
  cloud_inline_analysis = true

  rules = [
    {
      name     = "Block-Critical-High"
      severity = ["critical", "high"]
      category = "any"
      action = {
        drop = {}
      }
      packet_capture = "single-packet"
      threat_name    = "any"
    },
    {
      name     = "Alert-Medium-Low"
      severity = ["medium", "low"]
      category = "any"
      action = {
        alert = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
    },
    {
      name     = "Allow-Informational"
      severity = ["informational"]
      category = "any"
      action = {
        allow = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
    },
  ]
}


# -----------------------------------------------------------------------------
# Vulnerability Protection Profiles
# -----------------------------------------------------------------------------

resource "scm_vulnerability_protection_profile" "strict" {
  folder      = var.folder
  name        = "Vuln-Protection-Strict"
  description = "Strict IPS: reset on critical/high, drop medium, alert low"

  rules = [
    {
      name     = "Reset-Critical"
      severity = ["critical"]
      category = "any"
      host     = "any"
      action = {
        reset_both = {}
      }
      packet_capture = "extended-capture"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
    {
      name     = "Reset-High"
      severity = ["high"]
      category = "any"
      host     = "any"
      action = {
        reset_both = {}
      }
      packet_capture = "single-packet"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
    {
      name     = "Drop-Medium"
      severity = ["medium"]
      category = "any"
      host     = "any"
      action = {
        drop = {}
      }
      packet_capture = "single-packet"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
    {
      name     = "Alert-Low"
      severity = ["low"]
      category = "any"
      host     = "any"
      action = {
        alert = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
    {
      name     = "Allow-Informational"
      severity = ["informational"]
      category = "any"
      host     = "any"
      action = {
        allow = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
  ]
}

resource "scm_vulnerability_protection_profile" "standard" {
  folder      = var.folder
  name        = "Vuln-Protection-Standard"
  description = "Standard IPS: drop critical/high, alert medium/low"

  rules = [
    {
      name     = "Drop-Critical-High"
      severity = ["critical", "high"]
      category = "any"
      host     = "any"
      action = {
        drop = {}
      }
      packet_capture = "single-packet"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
    {
      name     = "Alert-Medium-Low"
      severity = ["medium", "low"]
      category = "any"
      host     = "any"
      action = {
        alert = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
    {
      name     = "Allow-Informational"
      severity = ["informational"]
      category = "any"
      host     = "any"
      action = {
        allow = {}
      }
      packet_capture = "disable"
      threat_name    = "any"
      cve            = ["any"]
      vendor_id      = ["any"]
    },
  ]
}


# -----------------------------------------------------------------------------
# DNS Security Profiles
# -----------------------------------------------------------------------------

resource "scm_dns_security_profile" "strict" {
  folder      = var.folder
  name        = "DNS-Security-Strict"
  description = "Strict DNS security: sinkhole malware/phishing, block C2/DGA"

  botnet_domains = {
    dns_security_categories = [
      {
        name           = "pan-dns-sec-malware"
        action         = "sinkhole"
        log_level      = "critical"
        packet_capture = "single-packet"
      },
      {
        name           = "pan-dns-sec-phishing"
        action         = "sinkhole"
        log_level      = "critical"
        packet_capture = "single-packet"
      },
      {
        name           = "pan-dns-sec-grayware"
        action         = "sinkhole"
        log_level      = "high"
        packet_capture = "disable"
      },
      {
        name           = "pan-dns-sec-recent"
        action         = "sinkhole"
        log_level      = "high"
        packet_capture = "disable"
      },
      {
        name           = "pan-dns-sec-proxy"
        action         = "block"
        log_level      = "high"
        packet_capture = "single-packet"
      },
      {
        name           = "pan-dns-sec-ddns"
        action         = "block"
        log_level      = "high"
        packet_capture = "disable"
      },
    ]

    sinkhole = {
      ipv4_address = "pan-sinkhole-default-ip"
      ipv6_address = "::1"
    }

    whitelist = [
      {
        name        = "internal.company.com"
        description = "Internal domain - exclude from DNS security"
      },
    ]
  }
}

resource "scm_dns_security_profile" "standard" {
  folder      = var.folder
  name        = "DNS-Security-Standard"
  description = "Standard DNS security: sinkhole malware, alert on grayware"

  botnet_domains = {
    dns_security_categories = [
      {
        name           = "pan-dns-sec-malware"
        action         = "sinkhole"
        log_level      = "critical"
        packet_capture = "single-packet"
      },
      {
        name           = "pan-dns-sec-phishing"
        action         = "sinkhole"
        log_level      = "high"
        packet_capture = "disable"
      },
      {
        name           = "pan-dns-sec-grayware"
        action         = "allow"
        log_level      = "informational"
        packet_capture = "disable"
      },
      {
        name           = "pan-dns-sec-recent"
        action         = "sinkhole"
        log_level      = "high"
        packet_capture = "disable"
      },
    ]

    sinkhole = {
      ipv4_address = "pan-sinkhole-default-ip"
      ipv6_address = "::1"
    }
  }
}


# -----------------------------------------------------------------------------
# File Blocking Profiles
# -----------------------------------------------------------------------------

resource "scm_file_blocking_profile" "strict" {
  folder      = var.folder
  name        = "File-Blocking-Strict"
  description = "Block dangerous file types, alert on documents"

  rules = [
    {
      name        = "Block-Executables-Upload"
      action      = "block"
      application = ["any"]
      direction   = "upload"
      file_type = [
        "exe", "dll", "bat", "cmd", "com", "cpl", "hta", "jar",
        "msi", "pif", "scr", "vbe", "vbs", "wsf",
      ]
    },
    {
      name        = "Block-Executables-Download"
      action      = "block"
      application = ["any"]
      direction   = "download"
      file_type = [
        "bat", "cmd", "com", "cpl", "dll", "hta", "jar",
        "msi", "pif", "scr", "vbe", "vbs", "wsf",
      ]
    },
    {
      name        = "Block-Archives-High-Risk"
      action      = "block"
      application = ["any"]
      direction   = "both"
      file_type = [
        "chm", "class", "hlp", "ocx", "torrent",
      ]
    },
    {
      name        = "Alert-Common-Docs"
      action      = "alert"
      application = ["any"]
      direction   = "both"
      file_type = [
        "doc", "docx", "xls", "xlsx", "ppt", "pptx", "pdf",
      ]
    },
    {
      name        = "Continue-EXE-Downloads"
      action      = "continue"
      application = ["web-browsing"]
      direction   = "download"
      file_type   = ["exe"]
    },
  ]
}

resource "scm_file_blocking_profile" "standard" {
  folder      = var.folder
  name        = "File-Blocking-Standard"
  description = "Block highest-risk file types only"

  rules = [
    {
      name        = "Block-Dangerous-Types"
      action      = "block"
      application = ["any"]
      direction   = "both"
      file_type = [
        "bat", "chm", "class", "cmd", "cpl", "dll", "hta",
        "jar", "ocx", "pif", "scr", "torrent", "vbe", "wsf",
      ]
    },
    {
      name        = "Alert-Executables"
      action      = "alert"
      application = ["any"]
      direction   = "both"
      file_type   = ["exe", "msi"]
    },
  ]
}


# -----------------------------------------------------------------------------
# Decryption Profiles
# -----------------------------------------------------------------------------

resource "scm_decryption_profile" "best_practice" {
  folder = var.folder
  name   = "Decryption-BestPractice"

  ssl_forward_proxy = {
    auto_include_altname              = true
    block_client_cert                 = false
    block_expired_certificate         = true
    block_timeout_cert                = true
    block_tls13_downgrade_no_resource = true
    block_unknown_cert                = false
    block_unsupported_cipher          = true
    block_unsupported_version         = true
    block_untrusted_issuer            = true
    restrict_cert_exts                = false
    strip_alpn                        = false
  }

  ssl_no_proxy = {
    block_expired_certificate = true
    block_untrusted_issuer    = false
  }

  ssl_protocol_settings = {
    auth_algo_md5              = false
    auth_algo_sha1             = true
    auth_algo_sha256           = true
    auth_algo_sha384           = true
    enc_algo_3des              = false
    enc_algo_aes_128_cbc       = true
    enc_algo_aes_128_gcm       = true
    enc_algo_aes_256_cbc       = true
    enc_algo_aes_256_gcm       = true
    enc_algo_chacha20_poly1305 = true
    enc_algo_rc4               = false
    keyxchg_algo_dhe           = true
    keyxchg_algo_ecdhe         = true
    keyxchg_algo_rsa           = false
    max_version                = "max"
    min_version                = "tls1-2"
  }
}
