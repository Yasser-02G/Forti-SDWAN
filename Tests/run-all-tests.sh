#!/usr/bin/env bash
#
# run-all-tests.sh
# Enchaîne les tests de validation de bout en bout.
#
# Usage : ./run-all-tests.sh <ip-forticasa> <ip-fortidakar> [user]

set -euo pipefail

CASA="${1:?Usage: $0 <ip-forticasa> <ip-fortidakar> [user]}"
DAKAR="${2:?Usage: $0 <ip-forticasa> <ip-fortidakar> [user]}"
USER="${3:-admin}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "### 1. Connectivité du transport (MPLS/Fibre) ###"
"${DIR}/test-transport-connectivity.sh" "${CASA}" "${DAKAR}" "${USER}"

echo
echo "### 2. Tunnels VPN - Forti-Casa ###"
"${DIR}/test-vpn-tunnels.sh" "${CASA}" "${USER}"

echo
echo "### 3. Tunnels VPN - Forti-Dakar ###"
"${DIR}/test-vpn-tunnels.sh" "${DAKAR}" "${USER}"

echo
echo "### 4. Service SD-WAN - Forti-Casa ###"
"${DIR}/test-sdwan-service.sh" "${CASA}" "${USER}"

echo
echo "### 5. Service SD-WAN - Forti-Dakar ###"
"${DIR}/test-sdwan-service.sh" "${DAKAR}" "${USER}"

echo
echo "### Tous les tests de base sont terminés. ###"
echo "Pour tester la bascule : ./test-sdwan-failover.sh <ip-fortigate>"
