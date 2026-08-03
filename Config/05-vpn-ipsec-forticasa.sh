#!/usr/bin/env bash
#
# 05-vpn-ipsec-forticasa.sh
# Crée les deux tunnels IPsec (VPN-MPLS sur port1, VPN-FIBRE sur port2)
# côté Forti-Casa, en miroir de Forti-Dakar.
#
# Corrections apportées par rapport à la documentation d'origine (SDWAN.docx) :
#   - proposal "des-sha256" -> "aes256-sha256"
#       (DES est un algorithme obsolète et cryptographiquement faible,
#        à ne plus utiliser même en labo)
#   - "set dst-subnet 0.0.0.0/" (masque manquant, typo) -> "0.0.0.0/0"
#   - la clé pré-partagée n'est plus codée en dur dans le script :
#     elle est lue depuis la variable d'environnement VPN_PSK pour éviter
#     de committer un secret dans le dépôt Git.
#
# Usage :
#   export VPN_PSK='VotreCléForte!'
#   ./05-vpn-ipsec-forticasa.sh <ip-fortigate> [user]

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
        set remote-gw 10.100.1.2
        set proposal aes256-sha256
        set dhgrp 14
        set net-device enable
        set psksecret ${PSK}
    next
    edit "VPN-FIBRE"
        set interface "port2"
        set ike-version 2
        set peertype any
        set remote-gw 10.200.1.2
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

echo "Tunnels VPN-MPLS et VPN-FIBRE configurés sur Forti-Casa."
