#!/usr/bin/env bash
#
# test-sdwan-failover.sh
# Automatise le scénario de bascule décrit dans la documentation d'origine :
#   1. Couper port1 (MPLS)
#   2. Vérifier que FIBRE devient le membre sélectionné
#   3. Restaurer port1 (MPLS)
#   4. Vérifier que MPLS redevient le membre sélectionné
#
# Usage : ./test-sdwan-failover.sh <ip-fortigate> [user] [wait_seconds]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user] [wait_seconds]}"
USER="${2:-admin}"
WAIT="${3:-15}"

set_port_status() {
    local status="$1"
    ssh "${USER}@${HOST}" <<EOF
config system interface
    edit "port1"
        set status ${status}
    end
end
EOF
}

check_selected_member() {
    ssh "${USER}@${HOST}" "diagnose sys sdwan service"
}

echo ">> État initial :"
check_selected_member

echo ">> Coupure de port1 (MPLS)..."
set_port_status down
sleep "${WAIT}"

echo ">> État après coupure (FIBRE attendu comme membre sélectionné) :"
RESULT_DOWN="$(check_selected_member)"
echo "${RESULT_DOWN}"

echo ">> Restauration de port1 (MPLS)..."
set_port_status up
sleep "${WAIT}"

echo ">> État après restauration (MPLS attendu comme membre sélectionné) :"
RESULT_UP="$(check_selected_member)"
echo "${RESULT_UP}"

echo "=> Comparer manuellement les 'Selected Member' ci-dessus avec le résultat attendu."
