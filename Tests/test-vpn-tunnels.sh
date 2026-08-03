#!/usr/bin/env bash
#
# test-vpn-tunnels.sh
# Vérifie l'état des tunnels IPsec VPN-MPLS et VPN-FIBRE (IKE + tunnel up)
# sur un FortiGate, comme dans la capture "État des tunnels VPN IPsec
# (MPLS et Fibre)".
#
# Usage : ./test-vpn-tunnels.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"

echo "=== IKE gateways ==="
IKE_OUTPUT="$(ssh "${USER}@${HOST}" "diagnose vpn ike gateway list")"
echo "${IKE_OUTPUT}"

echo
echo "=== Tunnels IPsec ==="
TUNNEL_OUTPUT="$(ssh "${USER}@${HOST}" "diagnose vpn tunnel list")"
echo "${TUNNEL_OUTPUT}"

FAIL=0
for TUNNEL in VPN-MPLS VPN-FIBRE; do
    if echo "${TUNNEL_OUTPUT}" | grep -A5 "name=${TUNNEL} " | grep -q "status=up" \
        && echo "${IKE_OUTPUT}" | grep -q "IKE SA Established"; then
        echo "[${TUNNEL}] UP"
    else
        echo "[${TUNNEL}] DOWN ou introuvable"
        FAIL=1
    fi
done

if [[ "${FAIL}" -eq 0 ]]; then
    echo "=> Les deux tunnels VPN sont opérationnels."
else
    echo "=> Au moins un tunnel VPN n'est pas up." >&2
    exit 1
fi
