# =============================================================================
# Zone Protection Profiles — Network-layer attack mitigation
# =============================================================================
# Zone protection profiles defend against volumetric attacks (floods),
# reconnaissance (port scans, host sweeps), and protocol-level exploits
# (IP spoofing, fragmentation attacks, malformed packets).
# =============================================================================

resource "scm_zone_protection_profile" "best_practice" {
  folder      = var.folder
  name        = "ZPP-Best-Practice"
  description = "Comprehensive zone protection per PAN best practices"

  # --- Flood Protection (RED = Random Early Drop) ---
  flood = {
    tcp_syn = {
      enable = true
      red = {
        alarm_rate    = 10000
        activate_rate = 20000
        maximal_rate  = 40000
      }
      syn_cookies = {
        alarm_rate    = 10000
        activate_rate = 20000
        maximal_rate  = 40000
      }
    }
    udp = {
      enable = true
      red = {
        alarm_rate    = 10000
        activate_rate = 20000
        maximal_rate  = 40000
      }
    }
    icmp = {
      enable = true
      red = {
        alarm_rate    = 5000
        activate_rate = 10000
        maximal_rate  = 20000
      }
    }
    icmpv6 = {
      enable = true
      red = {
        alarm_rate    = 5000
        activate_rate = 10000
        maximal_rate  = 20000
      }
    }
    other_ip = {
      enable = true
      red = {
        alarm_rate    = 5000
        activate_rate = 10000
        maximal_rate  = 20000
      }
    }
  }

  # --- Reconnaissance Protection (port scans & host sweeps) ---
  scan = [
    {
      name      = "8001"  # TCP Port Scan
      interval  = 2
      threshold = 100
      action = {
        block_ip = {
          duration = 300
          track_by = "source"
        }
      }
    },
    {
      name      = "8002"  # Host Sweep
      interval  = 10
      threshold = 100
      action = {
        block_ip = {
          duration = 300
          track_by = "source"
        }
      }
    },
    {
      name      = "8003"  # UDP Port Scan
      interval  = 2
      threshold = 100
      action = {
        block_ip = {
          duration = 300
          track_by = "source"
        }
      }
    },
  ]

  # --- Packet-Based Attack Protection ---
  # IP Options
  spoofed_ip_discard              = true
  strict_ip_check                 = true
  loose_source_routing_discard    = true
  strict_source_routing_discard   = true
  timestamp_discard               = true
  record_route_discard            = true
  security_discard                = true
  stream_id_discard               = true
  unknown_option_discard          = true
  malformed_option_discard        = true
  fragmented_traffic_discard      = false  # May break legitimate traffic
  discard_icmp_embedded_error     = false

  # ICMP Protection
  icmp_frag_discard               = true
  icmp_large_packet_discard       = true
  icmp_ping_zero_id_discard       = true
  suppress_icmp_needfrag          = false  # Required for PMTUD
  suppress_icmp_timeexceeded      = false

  # TCP Protection
  reject_non_syn_tcp              = "yes"
  tcp_syn_with_data_discard       = true
  tcp_synack_with_data_discard    = true
  tcp_handshake_discard           = true
  tcp_fast_open_and_data_strip    = true
  tcp_timestamp_strip             = false
  asymmetric_path                 = "drop"

  # TCP Segment Protection
  mismatched_overlapping_tcp_segment_discard = true

  # IPv6 Protection
  ipv6 = {
    anycast_source              = true
    needless_fragment_hdr       = true
    ipv4_compatible_address     = true
    reserved_field_set_discard  = true
    options_invalid_ipv6_discard = true
    routing_header_0            = true
    routing_header_1            = true
    routing_header_3            = false
    routing_header_4_252        = false
    routing_header_253          = false
    routing_header_254          = false
    routing_header_255          = true
    icmpv6_too_big_small_mtu_discard = true

    filter_ext_hdr = {
      dest_option_hdr = false
      hop_by_hop_hdr  = false
      routing_hdr     = false
    }

    ignore_inv_pkt = {
      dest_unreach  = false
      pkt_too_big   = false
      time_exceeded = false
      param_problem = false
      redirect      = true
    }
  }
}

# Lightweight profile for internal-only (trust) zones
resource "scm_zone_protection_profile" "internal" {
  folder      = var.folder
  name        = "ZPP-Internal"
  description = "Lighter zone protection for internal/trust zones"

  flood = {
    tcp_syn = {
      enable = true
      red = {
        alarm_rate    = 50000
        activate_rate = 75000
        maximal_rate  = 100000
      }
    }
    udp = {
      enable = true
      red = {
        alarm_rate    = 50000
        activate_rate = 75000
        maximal_rate  = 100000
      }
    }
  }

  spoofed_ip_discard            = true
  reject_non_syn_tcp            = "yes"
  tcp_syn_with_data_discard     = true
  mismatched_overlapping_tcp_segment_discard = true
  asymmetric_path               = "drop"
}
