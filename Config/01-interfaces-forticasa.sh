#!/usr/bin/env bash
#
# 01-interfaces-forticasa.sh
# Configure le hostname et les interfaces réseau du FortiGate de Casablanca.
#
# Plan d'adressage (Config/README.md) :
#   port1 (MPLS)  -> 10.100.0.2/24
#   port2 (FIBRE) -> 10.200.0.2/24
#   port3 (LAN)   -> 192.168.10.1/24
#
# Usage : ./01-interfaces-forticasa.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"

ssh "${USER}@${HOST}" <<'EOF'
config system global
    set hostname "Forti-Casa"
end

config system interface
    edit "port1"
        set alias "MPLS"
        set ip 10.100.0.2 255.255.255.0
        set allowaccess ping https ssh
    next
    edit "port2"
        set alias "FIBRE"
        set ip 10.200.0.2 255.255.255.0
        set allowaccess ping https ssh
    next
    edit "port3"
        set alias "LAN"
        set ip 192.168.10.1 255.255.255.0
        set allowaccess ping https ssh
    next
end
EOF

echo "Interfaces Forti-Casa configurées."
