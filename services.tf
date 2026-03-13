# =============================================================================
# Service Objects — Custom port definitions
# =============================================================================
# Defines application-specific services beyond the built-in App-ID defaults.
# Best practice: use App-ID in security rules where possible; define custom
# services only for non-standard ports or when App-ID cannot identify traffic.

# --- Web Services ---
resource "scm_service" "svc_https_8443" {
  folder      = var.folder
  name        = "SVC-HTTPS-8443"
  description = "HTTPS on alternate port 8443"
  protocol = {
    tcp = {
      port = "8443"
    }
  }
  tag = [scm_tag.managed_by_terraform.name]
}

resource "scm_service" "svc_http_8080" {
  folder      = var.folder
  name        = "SVC-HTTP-8080"
  description = "HTTP on alternate port 8080"
  protocol = {
    tcp = {
      port = "8080"
    }
  }
  tag = [scm_tag.managed_by_terraform.name]
}

# --- Database Services ---
resource "scm_service" "svc_mssql" {
  folder      = var.folder
  name        = "SVC-MSSQL"
  description = "Microsoft SQL Server"
  protocol = {
    tcp = {
      port = "1433"
      override = {
        timeout = 7200
      }
    }
  }
  tag = [scm_tag.tier_db.name]
}

resource "scm_service" "svc_postgresql" {
  folder      = var.folder
  name        = "SVC-PostgreSQL"
  description = "PostgreSQL database"
  protocol = {
    tcp = {
      port = "5432"
      override = {
        timeout = 7200
      }
    }
  }
  tag = [scm_tag.tier_db.name]
}

resource "scm_service" "svc_mysql" {
  folder      = var.folder
  name        = "SVC-MySQL"
  description = "MySQL / MariaDB database"
  protocol = {
    tcp = {
      port = "3306"
      override = {
        timeout = 7200
      }
    }
  }
  tag = [scm_tag.tier_db.name]
}

resource "scm_service" "svc_redis" {
  folder      = var.folder
  name        = "SVC-Redis"
  description = "Redis cache"
  protocol = {
    tcp = {
      port = "6379"
    }
  }
  tag = [scm_tag.tier_db.name]
}

# --- Infrastructure Services ---
resource "scm_service" "svc_syslog_udp" {
  folder      = var.folder
  name        = "SVC-Syslog-UDP"
  description = "Syslog over UDP"
  protocol = {
    udp = {
      port = "514"
    }
  }
}

resource "scm_service" "svc_syslog_tcp" {
  folder      = var.folder
  name        = "SVC-Syslog-TCP"
  description = "Syslog over TCP (reliable)"
  protocol = {
    tcp = {
      port = "514,6514"
    }
  }
}

resource "scm_service" "svc_ntp" {
  folder      = var.folder
  name        = "SVC-NTP"
  description = "Network Time Protocol"
  protocol = {
    udp = {
      port = "123"
    }
  }
}

resource "scm_service" "svc_snmp" {
  folder      = var.folder
  name        = "SVC-SNMP"
  description = "SNMP monitoring"
  protocol = {
    udp = {
      port = "161,162"
    }
  }
}

resource "scm_service" "svc_high_ephemeral" {
  folder      = var.folder
  name        = "SVC-Ephemeral-High"
  description = "High ephemeral ports for ALB health checks"
  protocol = {
    tcp = {
      port = "49152-65535"
    }
  }
}


# =============================================================================
# Service Groups — Logical groupings of services
# =============================================================================

resource "scm_service_group" "sg_web_services" {
  folder  = var.folder
  name    = "SG-Web-Services"
  members = [
    scm_service.svc_https_8443.name,
    scm_service.svc_http_8080.name,
  ]
  tag = [scm_tag.tier_web.name]
}

resource "scm_service_group" "sg_database_services" {
  folder  = var.folder
  name    = "SG-Database-Services"
  members = [
    scm_service.svc_mssql.name,
    scm_service.svc_postgresql.name,
    scm_service.svc_mysql.name,
    scm_service.svc_redis.name,
  ]
  tag = [scm_tag.tier_db.name]
}

resource "scm_service_group" "sg_logging_services" {
  folder  = var.folder
  name    = "SG-Logging-Services"
  members = [
    scm_service.svc_syslog_udp.name,
    scm_service.svc_syslog_tcp.name,
    scm_service.svc_snmp.name,
  ]
}

resource "scm_service_group" "sg_infrastructure" {
  folder  = var.folder
  name    = "SG-Infrastructure"
  members = [
    scm_service.svc_ntp.name,
    scm_service.svc_snmp.name,
    scm_service.svc_syslog_tcp.name,
    scm_service.svc_syslog_udp.name,
  ]
}
