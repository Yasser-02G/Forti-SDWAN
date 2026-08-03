#!/usr/bin/env bash
#
# test-transport-connectivity.sh
# Vérifie que le réseau de transport (liens MPLS et Fibre, avant tout VPN)
# est fonctionnel entre Forti-Casa et Forti-Dakar.
#
# Reproduit les tests de la doc d'origine :
#   Depuis Forti-Casa : ping 10.100.1.2 / ping 10.200.1.2
#   Depuis Forti-Dakar : ping 10.100.0.2 / ping 10.200.0.2
#
# Usage : ./test-transport-connectivity.sh <ip-forticasa> <ip-fortidakar> [user]

set -euo pipefail

CASA="${1:?Usage: $0 <ip-forticasa> <ip-fortidakar> [user]}"
DAKAR="${2:?Usage: $0 <ip-forticasa> <ip-fortidakar> [user]}"
USER="${3:-admin}"

FAIL=0

run_ping() {
    local host="$1" target="$2" label="$3"
    echo -n "[${label}] ${host} -> ${target} : "
    if ssh "${USER}@${host}" "execute ping-options repeat-count 3" \
        "execute ping ${target}" 2>/dev/null | grep -q "0% packet loss"; then
        echo "OK"
    else
        echo "ECHEC"
        FAIL=1
    fi
}

run_ping "${CASA}"  10.100.1.2 "Casa  -> Dakar via MPLS"
run_ping "${CASA}"  10.200.1.2 "Casa  -> Dakar via FIBRE"
run_ping "${DAKAR}" 10.100.0.2 "Dakar -> Casa  via MPLS"
run_ping "${DAKAR}" 10.200.0.2 "Dakar -> Casa  via FIBRE"

if [[ "${FAIL}" -eq 0 ]]; then
    echo "=> Réseau de transport fonctionnel."
else
    echo "=> Au moins un test a échoué, vérifier le câblage / les interfaces." >&2
    exit 1
fi
