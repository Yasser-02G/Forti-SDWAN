#!/usr/bin/env bash
#
# 10-sdwan-forticasa.sh
# Configure la zone SD-WAN (virtual-wan-link), les health-checks et la
# règle de sélection dynamique du chemin sur Forti-Casa.
#
# Reconstitué à partir de :
#   - SDWAN.docx (mode priority, health-check MPLS/FIBRE, priority-members 1 2)
#   - la capture "Configuration de la zone SD-WAN (Virtual-WAN-Link)" :
#     zone "virtual-wan-link" contenant MPLS(port1) + FIBRE(port2)
#   - la capture "Configuration de la règle SD-WAN ... Casablanca" :
#     règle "LAN_TO_DAKAR", membres MPLS(port1, route sélectionnée) +
#     FIBRE(port2), critère "Latency"
#
# NOTE : l'adresse serveur des health-checks n'était pas précisée dans la
# documentation d'origine. Elle est ici positionnée sur l'IP distante du
# lien transporteur (10.100.1.2 pour MPLS, 10.200.1.2 pour FIBRE) ; à
# ajuster si un autre serveur de test (ex: DNS public) est préférable.
#
# Usage : ./10-sdwan-forticasa.sh <ip-fortigate> [user]

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
            set server "10.100.1.2"
            set members 1
        next
        edit "FIBRE"
            set server "10.200.1.2"
            set members 2
        next
    end

    config service
        edit 1
            set name "LAN_TO_DAKAR"
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

echo "SD-WAN (zone + health-check + règle LAN_TO_DAKAR) configuré sur Forti-Casa."
