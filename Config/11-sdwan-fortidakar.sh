#!/usr/bin/env bash
#
# 11-sdwan-fortidakar.sh
# Configure la zone SD-WAN (virtual-wan-link), les health-checks et la
# règle de sélection dynamique du chemin sur Forti-Dakar.
#
# Miroir de 10-sdwan-forticasa.sh, cf. capture "Configuration de la règle
# SD-WAN ... Dakar" : règle "LAN_TO_CASA", membres MPLS(port1, route
# sélectionnée) + FIBRE(port2), critère "Latency".
#
# NOTE : mêmes réserves que côté Casa sur l'adresse des health-checks.
#
# Usage : ./11-sdwan-fortidakar.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"

ssh "${USER}@${HOST}" <<'EOF'
config system sdwan
    config zone
        edit "virtual-wan-link"
        next
    end

    config members
        edit 1
            set interface "port1"
            set zone "virtual-wan-link"
        next
        edit 2
            set interface "port2"
            set zone "virtual-wan-link"
        next
    end

    config health-check
        edit "MPLS"
            set server "10.100.0.2"
            set members 1
        next
        edit "FIBRE"
            set server "10.200.0.2"
            set members 2
        next
    end

    config service
        edit 1
            set name "LAN_TO_CASA"
            set mode priority
            set src "all"
            set dst "all"
            set health-check "MPLS" "FIBRE"
            set link-cost-factor latency
            set priority-members 1 2
        next
    end
end
EOF

echo "SD-WAN (zone + health-check + règle LAN_TO_CASA) configuré sur Forti-Dakar."
