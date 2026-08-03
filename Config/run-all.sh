#!/usr/bin/env bash
#
# run-all.sh
# Orchestre le déploiement complet de la configuration SD-WAN sur les
# deux FortiGate, dans l'ordre attendu.
#
# Prérequis :
#   - accès SSH activé sur port1/port2/port3 des deux FortiGate
#   - variable d'environnement VPN_PSK positionnée (clé pré-partagée IPsec)
#
# Usage :
#   export VPN_PSK='VotreCléForte!'
#   ./run-all.sh <ip-forticasa> <ip-fortidakar> [user]

set -euo pipefail

CASA="${1:?Usage: $0 <ip-forticasa> <ip-fortidakar> [user]}"
DAKAR="${2:?Usage: $0 <ip-forticasa> <ip-fortidakar> [user]}"
USER="${3:-admin}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== 1. Interfaces ==="
"${DIR}/01-interfaces-forticasa.sh" "${CASA}" "${USER}"
"${DIR}/02-interfaces-fortidakar.sh" "${DAKAR}" "${USER}"

echo "=== 2. Routes statiques (transport) ==="
"${DIR}/04-static-routes.sh" "${CASA}" casa "${USER}"
"${DIR}/04-static-routes.sh" "${DAKAR}" dakar "${USER}"

echo "=== 3. Tunnels VPN IPsec ==="
"${DIR}/05-vpn-ipsec-forticasa.sh" "${CASA}" "${USER}"
"${DIR}/06-vpn-ipsec-fortidakar.sh" "${DAKAR}" "${USER}"

echo "=== 4. Routes statiques (LAN distant via VPN) ==="
"${DIR}/07-static-routes-vpn.sh" "${CASA}" casa "${USER}"
"${DIR}/07-static-routes-vpn.sh" "${DAKAR}" dakar "${USER}"

echo "=== 5. Politiques de sécurité ==="
"${DIR}/08-firewall-policies-forticasa.sh" "${CASA}" "${USER}"
"${DIR}/09-firewall-policies-fortidakar.sh" "${DAKAR}" "${USER}"

echo "=== 6. SD-WAN (zone + health-check + règle) ==="
"${DIR}/10-sdwan-forticasa.sh" "${CASA}" "${USER}"
"${DIR}/11-sdwan-fortidakar.sh" "${DAKAR}" "${USER}"

echo "=== Déploiement terminé. Lancer les tests dans ../Tests/ pour valider. ==="
