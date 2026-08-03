#!/usr/bin/env bash
#
# 02-interfaces-fortidakar.sh
# Configure le hostname et les interfaces réseau du FortiGate de Dakar.
#
# Plan d'adressage (Config/README.md) :
#   port1 (MPLS)  -> 10.100.1.2/24
#   port2 (FIBRE) -> 10.200.1.2/24
#   port3 (LAN)   -> 192.168.20.1/24
#
# Usage : ./02-interfaces-fortidakar.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"

ssh "${USER}@${HOST}" <<'EOF'
config system global
    set hostname "Forti-Dakar"
end

config system interface
    edit "port1"
        set alias "MPLS"
        set ip 10.100.1.2 255.255.255.0
        set allowaccess ping https ssh
    next
    edit "port2"
        set alias "FIBRE"
        set ip 10.200.1.2 255.255.255.0
        set allowaccess ping https ssh
    next
    edit "port3"
        set alias "LAN"
        set ip 192.168.20.1 255.255.255.0
        set allowaccess ping https ssh
    next
end
EOF

echo "Interfaces Forti-Dakar configurées."
