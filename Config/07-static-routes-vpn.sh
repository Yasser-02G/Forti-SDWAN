#!/usr/bin/env bash
#
# 07-static-routes-vpn.sh
# Ajoute les routes statiques vers le LAN distant à travers les tunnels
# VPN : route principale via VPN-MPLS, route de secours via VPN-FIBRE
# (distance administrative 20, donc utilisée uniquement si VPN-MPLS est down).
#
# Sans ces routes, le LAN distant (192.168.10.0/24 ou 192.168.20.0/24)
# n'est pas routé à travers les tunnels IPsec, comme constaté dans la
# documentation d'origine.
#
# Usage : ./07-static-routes-vpn.sh <ip-fortigate> <site: casa|dakar> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> <site: casa|dakar> [user]}"
SITE="${2:?Usage: $0 <ip-fortigate> <site: casa|dakar> [user]}"
USER="${3:-admin}"

case "${SITE}" in
    casa)
        REMOTE_LAN="192.168.20.0 255.255.255.0"
        ;;
    dakar)
        REMOTE_LAN="192.168.10.0 255.255.255.0"
        ;;
    *)
        echo "Site inconnu : ${SITE} (attendu: casa | dakar)" >&2
        exit 1
        ;;
esac

ssh "${USER}@${HOST}" <<EOF
config router static
    edit 3
        set dst ${REMOTE_LAN}
        set device "VPN-MPLS"
    next
    edit 4
        set dst ${REMOTE_LAN}
        set device "VPN-FIBRE"
        set distance 20
    next
end
get router info routing-table details
EOF

echo "Routes vers le LAN distant (via VPN-MPLS puis VPN-FIBRE) ajoutées sur ${HOST} (${SITE})."
