#!/usr/bin/env bash
#
# test-wan-quality-simulation.sh
# Applique (ou retire) une simulation de qualité de lien avec `tc netem`
# sur les routeurs VyOS Cloud-MPLS et Cloud-Fibre, afin de tester le
# critère de sélection SD-WAN basé sur la latence.
#
# Profils repris de la documentation d'origine :
#   Cloud-MPLS  : delay 5ms  1ms  loss 0.05%
#   Cloud-Fibre : delay 25ms 5ms  loss 0.5%
#
# Usage :
#   ./test-wan-quality-simulation.sh apply  <ip-cloud-mpls> <ip-cloud-fibre> [user]
#   ./test-wan-quality-simulation.sh clear  <ip-cloud-mpls> <ip-cloud-fibre> [user]
#   ./test-wan-quality-simulation.sh show   <ip-cloud-mpls> <ip-cloud-fibre> [user]

set -euo pipefail

ACTION="${1:?Usage: $0 <apply|clear|show> <ip-cloud-mpls> <ip-cloud-fibre> [user]}"
MPLS_HOST="${2:?Usage: $0 <apply|clear|show> <ip-cloud-mpls> <ip-cloud-fibre> [user]}"
FIBRE_HOST="${3:?Usage: $0 <apply|clear|show> <ip-cloud-mpls> <ip-cloud-fibre> [user]}"
USER="${4:-vyos}"

case "${ACTION}" in
    apply)
        ssh "${USER}@${MPLS_HOST}" <<'EOF'
sudo tc qdisc add dev eth0 root netem delay 5ms 1ms loss 0.05%
sudo tc qdisc add dev eth1 root netem delay 5ms 1ms loss 0.05%
sudo tc qdisc show | grep netem
EOF
        ssh "${USER}@${FIBRE_HOST}" <<'EOF'
sudo tc qdisc add dev eth0 root netem delay 25ms 5ms loss 0.5%
sudo tc qdisc add dev eth1 root netem delay 25ms 5ms loss 0.5%
sudo tc qdisc show | grep netem
EOF
        echo "Profils de latence/perte appliqués (MPLS: 5ms/0.05%, FIBRE: 25ms/0.5%)."
        ;;
    clear)
        ssh "${USER}@${MPLS_HOST}" 'sudo tc qdisc del dev eth0 root; sudo tc qdisc del dev eth1 root'
        ssh "${USER}@${FIBRE_HOST}" 'sudo tc qdisc del dev eth0 root; sudo tc qdisc del dev eth1 root'
        echo "Simulation de latence/perte retirée sur les deux clouds."
        ;;
    show)
        echo "=== Cloud-MPLS ==="
        ssh "${USER}@${MPLS_HOST}" 'sudo tc qdisc show | grep netem || echo "(aucun netem actif)"'
        echo "=== Cloud-Fibre ==="
        ssh "${USER}@${FIBRE_HOST}" 'sudo tc qdisc show | grep netem || echo "(aucun netem actif)"'
        ;;
    *)
        echo "Action inconnue : ${ACTION} (attendu: apply | clear | show)" >&2
        exit 1
        ;;
esac
