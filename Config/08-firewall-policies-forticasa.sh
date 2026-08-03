#!/usr/bin/env bash
#
# 08-firewall-policies-forticasa.sh
# Politiques de sécurité entre le LAN (port3) et les deux tunnels VPN,
# côté Forti-Casa.
#
# CORRECTION par rapport à la documentation d'origine :
#   La doc signalait que la politique de retour "VPN-FIBRE -> LAN"
#   était absente côté Dakar en raison d'une limitation de licence.
#   Sans cette règle, le trafic initié depuis le LAN distant vers
#   Casablanca via le lien Fibre est bloqué au retour (asymétrie).
#   Elle est donc explicitement ajoutée ici (edit 4) pour les deux sites.
#
# Usage : ./08-firewall-policies-forticasa.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"

ssh "${USER}@${HOST}" <<'EOF'
config firewall policy
    edit 1
        set name "LAN_to_DAKAR_MPLS"
        set srcintf "port3"
        set dstintf "VPN-MPLS"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 2
        set name "DAKAR_to_LAN_MPLS"
        set srcintf "VPN-MPLS"
        set dstintf "port3"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 3
        set name "LAN_to_DAKAR_FIBRE"
        set srcintf "port3"
        set dstintf "VPN-FIBRE"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    edit 4
        set name "DAKAR_to_LAN_FIBRE"
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

echo "Politiques de sécurité LAN <-> VPN (MPLS + FIBRE) configurées sur Forti-Casa."
