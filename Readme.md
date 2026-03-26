# Zabbix Template for DNSBL Monitoring

This repository provides a Zabbix 7.0 template for monitoring servers in DNSBL (Domain Name System Blacklist) lists. It helps in identifying potential mail delivery issues by tracking whether your server's IP address is listed in common RBL/DNSBL services.

## Overview

The template uses an external shell script and file with example of rbl lists to discover and check multiple RBL zones. It uses Zabbix Low-Level Discovery (LLD) to manage the list of monitoring services. You can edit dnsblcheck_blacklist.txt and zabbix will autodiscover it and add new lists for monitoring.

### Key Features

- Automated discovery of RBL zones from a configuration file.
- Item prototypes for checking the host IP against discovered RBLs.
- Built-in triggers for alerting when a host is blacklisted.

## Requirements

- Zabbix 7.0+.
- `dig` or `host` utility installed on the Zabbix server.
- External script support enabled in Zabbix configuration.

## Installation

### 1. Script Setup

Copy `rbl_check.sh` and `dnsblcheck_blacklist.txt` files from the repository to your Zabbix external scripts directory (usually `/usr/lib/zabbix/externalscripts`).


Ensure the script is executable:
```bash
chmod +x /usr/lib/zabbix/externalscripts/rbl_check.sh
chown zabbix:zabbix /usr/lib/zabbix/externalscripts/rbl_check.sh
```

### 2. Import Template

1. Download the `Template DNSBL external.yaml` file.
2. In the Zabbix web interface, go to **Data collection > Templates**.
3. Click **Import** and select the YAML file.
4. Click **Import** to finish.

### 3. Assign Template

Assign the "Template DNSBL external" to the hosts (e.g., Mail Servers) you want to monitor. Ensure the hosts have a valid IP address configured in their interfaces.

## Configuration

### rbl_check.sh
The script should support two modes of operation:
1. `discovery`: Returns a JSON object for Zabbix LLD containing the list of RBL zones from `dnsblcheck_blacklist.txt`.
2. `check`: Performs the actual DNS lookup for a specific IP and RBL zone.

### dnsblcheck_blacklist.txt
This file should contain one RBL zone per line. For example:
```text
zen.spamhaus.org
bl.spamcop.net
dnsbl.sorbs.net
```

## Monitoring Details

### Items
- **RBL zones discovery**: Discovers RBL zones every 1 hour.
- **DNSBL {#RBL}**: Checks the host IP against each discovered RBL zone every 15 minutes.

### Triggers
- Alert triggered when the check returns a status of "Listed" (1). Severity: Warning.

## Troubleshooting

- Ensure that the Zabbix server can perform outbound DNS queries to the RBL services.
- Verify that `ExternalScripts` parameter in `zabbix_server.conf` or `zabbix_proxy.conf` points to the correct directory.
- Test the script manually as the `zabbix` user:
  ```bash
  /usr/lib/zabbix/externalscripts/rbl_check.sh check 1.2.3.4 zen.spamhaus.org
  ```
