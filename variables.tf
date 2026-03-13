# =============================================================================
# Variables
# =============================================================================

variable "folder" {
  description = "SCM folder where all configuration objects will be created. For VM-Series managed by SCM, this is typically 'ngfw-shared' or a custom folder name."
  type        = string
  default     = "ngfw-shared"
}

variable "trusted_network" {
  description = "Internal/trusted network CIDR block"
  type        = string
  default     = "10.0.0.0/8"
}

variable "dmz_network" {
  description = "DMZ network CIDR block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR block where the VM-Series is deployed"
  type        = string
  default     = "10.100.0.0/16"
}

variable "dns_servers" {
  description = "List of DNS server IPs"
  type        = list(string)
  default     = ["10.100.1.10", "10.100.1.11"]
}

variable "nat_egress_ip" {
  description = "Untrust interface IP for outbound source NAT (update to match your VM-Series EIP/private IP)"
  type        = string
  default     = "10.100.0.10/32"
}

variable "public_vip" {
  description = "Public-facing IP (EIP) for inbound DNAT to web servers"
  type        = string
  default     = "10.100.0.10/32"
}

variable "syslog_server" {
  description = "Syslog server profile name (must exist in SCM)"
  type        = string
  default     = "default-syslog"
}
