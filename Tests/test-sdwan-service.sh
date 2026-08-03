#!/usr/bin/env bash
#
# test-sdwan-service.sh
# Vérifie la règle SD-WAN, l'état des health-checks et le membre
# actuellement sélectionné (attendu : MPLS en priorité).
#
# Usage : ./test-sdwan-service.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"

echo "=== show system sdwan ==="
ssh "${USER}@${HOST}" "show system sdwan"

echo
echo "=== diagnose sys sdwan health-check ==="
ssh "${USER}@${HOST}" "diagnose sys sdwan health-check"

echo
echo "=== diagnose sys sdwan service ==="
ssh "${USER}@${HOST}" "diagnose sys sdwan service"
