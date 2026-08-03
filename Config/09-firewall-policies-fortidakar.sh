#!/usr/bin/env bash
#
# 09-firewall-policies-fortidakar.sh
# Politiques de sécurité entre le LAN (port3) et les deux tunnels VPN,
# côté Forti-Dakar.
#
# La capture d'écran d'origine ("Configuration des politiques de sécurité
# ... sur le site de Dakar") ne montre que 3 règles :
#   LAN(port3) -> VPN-FIBRE
#   LAN(port3) -> VPN-MPLS
#   VPN-MPLS   -> LAN(port3)
# La règle de retour "VPN-FIBRE -> LAN" manquait (limitation de licence
# signalée dans la documentation). Elle est ajoutée ici en edit 4 pour
# corriger l'asymétrie de trafic sur le lien Fibre.
#
# Usage : ./09-firewall-policies-fortidakar.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"

ssh "${USER}@${HOST}" <<'EOF'
config firewall policy
    edit 1
        set name "LAN_to_CASA_FIBRE"
        set srcintf "port3"
        set dstintf "VPN-FIBRE"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 2
        set name "LAN_to_CASA_MPLS"
        set srcintf "port3"
        set dstintf "VPN-MPLS"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 3
        set name "CASA_to_LAN_MPLS"
        set srcintf "VPN-MPLS"
        set dstintf "port3"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 4
        set name "CASA_to_LAN_FIBRE"
        set srcintf "VPN-FIBRE"
        set dstintf "port3"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
end
EOF

echo "Politiques de sécurité LAN <-> VPN (MPLS + FIBRE) configurées sur Forti-Dakar."
