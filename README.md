# VM-Series Golden Configuration via Strata Cloud Manager

## Overview

This Terraform project deploys a comprehensive "golden configuration" to a Palo Alto Networks VM-Series firewall in AWS through **Strata Cloud Manager (SCM)**. It demonstrates how every aspect of a next-generation firewall can be automated as Infrastructure-as-Code using the `PaloAltoNetworks/scm` Terraform provider.

This project has been validated end-to-end against the SCM API (provider v1.0.8) and commits cleanly from a shared folder.

## What Gets Deployed

| Category | Resources | Count |
|---|---|---|
| **Tags** | Environment, tier, compliance, and classification tags | 10 |
| **Address Objects** | IP-netmask, IP-range, FQDN, wildcard types | 15 |
| **Address Groups** | Static groups + dynamic (tag-based) groups | 7 |
| **Service Objects** | TCP/UDP custom port definitions with timeouts | 10 |
| **Service Groups** | Logical service groupings | 4 |
| **Anti-Spyware Profiles** | Strict (reset/drop) and Standard (drop/alert) | 2 |
| **Vulnerability Protection** | Strict (reset/drop) and Standard (drop/alert) | 2 |
| **DNS Security Profiles** | Category-based sinkholing and blocking | 2 |
| **File Blocking Profiles** | Block dangerous types, alert on documents | 2 |
| **Decryption Profiles** | TLS 1.2+ forward proxy best practice | 1 |
| **Security Profile Groups** | Strict and Standard bundles | 2 |
| **Log Forwarding Profiles** | Full SIEM forwarding + traffic-only | 2 |
| **Zone Protection Profiles** | Flood, recon, and packet-based attack protection | 2 |
| **Security Zones** | Trust, Untrust, DMZ with zone protection | 3 |
| **Security Rules** | Layered rulebase (deny→infra→app→internet→deny-all) | 14 |
| **NAT Rules** | Outbound source NAT + inbound destination NAT | 3 |

> **Note:** Ethernet interfaces are included in `interfaces.tf` but commented out. See [SCM Provider Gotchas](#scm-provider-gotchas) for details.

## Prerequisites

1. **Strata Cloud Manager tenant** with a firewall onboarded
2. **Service account** with API access ([create one here](https://docs.paloaltonetworks.com/common-services/identity-and-access-access-management/manage-identity-and-access/add-service-accounts))
3. **Terraform** >= 1.4.6
4. **SCM Provider** >= 1.0.8 (auto-downloaded by `terraform init`)

## Authentication

Export the following environment variables before running Terraform:

```bash
export SCM_CLIENT_ID="your-client-id"
export SCM_CLIENT_SECRET="your-client-secret"
export SCM_TSG_ID="your-tsg-id"
export SCM_SCOPE="tsg_id:your-tsg-id"
```

> **Important:** `SCM_SCOPE` must be the literal string `tsg_id:<your-tsg-id>`. Do **not** use shell variable interpolation or Terraform variables for the scope value — the API will reject it.

## Usage

```bash
# Initialize the provider
terraform init

# Preview changes (update folder to match your SCM container)
terraform plan -var="folder=<your_folder>"

# Deploy the golden config
terraform apply -var="folder=<your_folder>"

# Push the candidate config in SCM to make it active
# (This step is done in the SCM UI or via the scm_config_versions resource)
```

## Customization

Edit `variables.tf` to adjust:

- `folder` — SCM folder targeting your firewall (default: `ngfw-shared`)
- `trusted_network` — Your internal CIDR (default: `10.0.0.0/8`)
- `dmz_network` — Your DMZ CIDR (default: `172.16.0.0/16`)
- `aws_vpc_cidr` — Your AWS VPC CIDR (default: `10.100.0.0/16`)
- `dns_servers` — Your DNS server IPs
- `nat_egress_ip` — The untrust interface IP for outbound source NAT (default: `10.100.0.10/32`)

## File Structure

```
golden-config/
├── versions.tf            # Provider & Terraform version constraints
├── variables.tf           # Input variables
├── tags.tf                # Organizational tags
├── addresses.tf           # Address objects & address groups
├── services.tf            # Service objects & service groups
├── security_profiles.tf   # Anti-spyware, vuln, DNS, file blocking, decryption
├── profile_groups.tf      # Security profile groups (strict + standard)
├── log_forwarding.tf      # Log forwarding profiles
├── zone_protection.tf     # Zone protection profiles (flood, recon, packet)
├── zones.tf               # Security zones (trust, untrust, DMZ)
├── interfaces.tf          # Ethernet interfaces (commented out — see gotchas)
├── security_policy.tf     # Security rulebase
├── nat_policy.tf          # NAT rules (SNAT + DNAT)
├── outputs.tf             # Output values
└── README.md              # This file
```

## Known Limitations

- **Config push** — Terraform creates a candidate configuration. You must push/commit it in SCM to activate it on the firewall.

## SCM Provider Gotchas

The following behaviors were discovered through testing against the live SCM API (v1.0.8).

### Security Rules (`scm_security_rule`)

- **`source_user` is required.** The Terraform schema marks it as optional, but the SCM API rejects any security rule that omits it. Always include `source_user = ["any"]`.
- **`category` is required and cannot be empty.** Setting `category = []` or omitting it entirely both cause API errors. Always include `category = ["any"]`.

### Address Objects (`scm_address`)

- **`ip_wildcard` type does not support tags.** Adding a `tag` attribute to an address object using `ip_wildcard` will fail with an "Invalid Object" error. All other address types (ip_netmask, ip_range, fqdn) support tags normally.

### Ethernet Interfaces (`scm_ethernet_interface`)

- **Interface names use template variable format.** SCM expects names like `$ethernet1_1`, not PAN-OS format `ethernet1/1`. The slash character fails regex validation.
- **Template variables require device-level mappings.** Interfaces defined with `$variable` names can only be committed when the target folder/container has a device with matching variable definitions. Pushing from a generic shared folder will fail at commit time with "unresolved variables" errors.
- **For AWS VM-Series, interfaces are bootstrapped.** In most AWS deployments, interface configuration is handled via init-cfg.txt/userdata and is device-specific. Interface resources are included in this project as commented-out examples for reference.

### NAT Rules (`scm_nat_rule`)

- **Avoid `interface_address` in shared folders.** Interface-based source NAT (`interface_address = { interface = "..." }`) requires resolved template variables. For folder-based configs, use `translated_address` with an address object instead.
- **`dynamic_ip_and_port.translated_address` is a list of strings**, not a nested object. The correct syntax is:
  ```hcl
  source_translation = {
    dynamic_ip_and_port = {
      translated_address = ["My-NAT-Address"]
    }
  }
  ```

### Vulnerability Protection Profiles (`scm_vulnerability_protection_profile`)

- **`default = {}` is not a valid action for rules.** Although it appears in the schema documentation, the API rejects it in the `rules` block. Use a concrete action (`allow`, `alert`, `drop`, `reset_both`, etc.) instead. The `default` action is only valid inside `threat_exception` blocks.

### File Blocking Profiles (`scm_file_blocking_profile`)

- **Not all file type keywords are valid.** For example, `ps1` (PowerShell) is not recognized as a valid file type. Validate file type keywords against your PAN-OS/SCM version before using them.
- **Application names in file blocking rules follow App-ID naming.** Generic names like `ssl` are not valid — use the specific App-ID name (e.g., `web-browsing`). Check the App-ID database in SCM for valid application names.

### General Tips

- **Iterate with `terraform apply -parallelism=1`** when debugging. This serializes API calls and makes error output easier to follow.
- **SCM authentication rate limits** apply to JWT token requests (~10 concurrent). For CI/CD pipelines, consider the token caching approach described in the provider's GitHub README.

## Security Posture Summary

The golden config implements a **defense-in-depth** strategy:

1. **Network segmentation** — Three zones with zone protection profiles
2. **Application-aware policy** — App-ID based rules, not port-based
3. **Threat prevention on every rule** — Anti-spyware, IPS, DNS security, file blocking
4. **Least privilege** — Explicit deny-all at the bottom of the rulebase
5. **Anti-spoofing** — RFC1918 blocking on untrust ingress + zone protection
6. **Protocol enforcement** — QUIC blocked to force TLS inspection
7. **SSL/TLS best practice** — TLS 1.2 minimum, no RC4, no 3DES
8. **Comprehensive logging** — All rules log to SIEM via log forwarding profiles
