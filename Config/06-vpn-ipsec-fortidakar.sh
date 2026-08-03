#!/usr/bin/env bash
#
# 06-vpn-ipsec-fortidakar.sh
# Crée les deux tunnels IPsec (VPN-MPLS sur port1, VPN-FIBRE sur port2)
# côté Forti-Dakar, en miroir de Forti-Casa.
#
# Mêmes corrections que 05-vpn-ipsec-forticasa.sh :
#   - proposal aes256-sha256 (au lieu de des-sha256, obsolète)
#   - dst-subnet 0.0.0.0/0 (typo corrigée)
#   - PSK lue depuis la variable d'environnement VPN_PSK (jamais commitée)
#
# Usage :
#   export VPN_PSK='VotreCléForte!'
#   ./06-vpn-ipsec-fortidakar.sh <ip-fortigate> [user]

set -euo pipefail

HOST="${1:?Usage: $0 <ip-fortigate> [user]}"
USER="${2:-admin}"
PSK="${VPN_PSK:?Erreur: définissez la variable d'environnement VPN_PSK (clé pré-partagée IPsec) avant d'exécuter ce script}"

ssh "${USER}@${HOST}" <<EOF
config vpn ipsec phase1-interface
    edit "VPN-MPLS"
        set interface "port1"
        set ike-version 2
        set peertype any
        set remote-gw 10.100.0.2
        set proposal aes256-sha256
        set dhgrp 14
        set net-device enable
        set psksecret ${PSK}
    next
    edit "VPN-FIBRE"
        set interface "port2"
        set ike-version 2
        set peertype any
        set remote-gw 10.200.0.2
        set proposal aes256-sha256
        set dhgrp 14
        set net-device enable
        set psksecret ${PSK}
    next
end

config vpn ipsec phase2-interface
    edit "VPN-MPLS-P2"
        set phase1name "VPN-MPLS"
        set proposal aes256-sha256
        set pfs disable
        set auto-negotiate enable
        set src-subnet 0.0.0.0/0
        set dst-subnet 0.0.0.0/0
    next
    edit "VPN-FIBRE-P2"
        set phase1name "VPN-FIBRE"
        set proposal aes256-sha256
        set pfs disable
        set auto-negotiate enable
        set src-subnet 0.0.0.0/0
        set dst-subnet 0.0.0.0/0
    next
end
EOF

echo "Tunnels VPN-MPLS et VPN-FIBRE configurés sur Forti-Dakar."
