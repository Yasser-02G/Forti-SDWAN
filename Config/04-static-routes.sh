#!/usr/bin/env bash
#
# 04-static-routes.sh
# Configure les routes statiques par défaut (transport MPLS + Fibre)
# sur un FortiGate (Casa ou Dakar).
#
# Usage : ./04-static-routes.sh <ip-fortigate> <site: casa|dakar> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> <site: casa|dakar> [user]}"
SITE="${2:?Usage: $0 <ip-fortigate> <site: casa|dakar> [user]}"
USER="${3:-admin}"

case "${SITE}" in
    casa)
        GW_MPLS="10.100.0.1"
        GW_FIBRE="10.200.0.1"
        ;;
    dakar)
        GW_MPLS="10.100.1.1"
        GW_FIBRE="10.200.1.1"
        ;;
    *)
        echo "Site inconnu : ${SITE} (attendu: casa | dakar)" >&2
        exit 1
        ;;
esac

ssh "${USER}@${HOST}" <<EOF
config router static
    edit 1
        set gateway ${GW_MPLS}
        set device "port1"
    next
    edit 2
        set gateway ${GW_FIBRE}
        set device "port2"
    next
end
get router info routing-table all
EOF

echo "Routes statiques configurées sur ${HOST} (${SITE})."
