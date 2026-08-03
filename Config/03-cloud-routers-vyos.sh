#!/usr/bin/env bash
#
# 03-cloud-routers-vyos.sh
# Configure les deux routeurs VyOS qui simulent les liens WAN
# (Cloud-MPLS et Cloud-Fibre) dans la topologie GNS3.
#
# Usage : ./03-cloud-routers-vyos.sh <ip-cloud-mpls> <ip-cloud-fibre> [user]

set -euo pipefail

MPLS_HOST="${1:?Usage: $0 <ip-cloud-mpls> <ip-cloud-fibre> [user]}"
FIBRE_HOST="${2:?Usage: $0 <ip-cloud-mpls> <ip-cloud-fibre> [user]}"
USER="${3:-vyos}"

echo ">> Configuration de Cloud-MPLS (${MPLS_HOST})"
ssh "${USER}@${MPLS_HOST}" <<'EOF'
configure
set system host-name Cloud-MPLS
set interfaces ethernet eth0 address '10.100.0.1/24'
set interfaces ethernet eth1 address '10.100.1.1/24'
commit
save
EOF

echo ">> Configuration de Cloud-Fibre (${FIBRE_HOST})"
ssh "${USER}@${FIBRE_HOST}" <<'EOF'
configure
set system host-name Cloud-Fibre
set interfaces ethernet eth0 address '10.200.0.1/24'
set interfaces ethernet eth1 address '10.200.1.1/24'
commit
save
EOF

echo "Routeurs cloud (VyOS) configurés."
