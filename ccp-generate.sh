#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${PEERNAME1}/$6/" \
        -e "s/\${PEERNAME2}/$7/" \
        -e "s/\${P1PORT}/$8/" \
        ../ccp-files/ccp-osoq-methodbridge.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s/\${PEERNAME1}/$6/" \
        -e "s/\${PEERNAME2}/$7/" \
        -e "s/\${P1PORT}/$8/" \
        ../ccp-files/ccp-osoq-methodbridge.yaml | sed -e $'s/\\\\n/\\\n          /g'
}


# generating ccp for org

ORG="osqoNewOrg"
P0PORT=15051
P1PORT=16051
CAPORT=12054
PEERPEM=../organizations/peerOrganizations/$ORG.methodbridge.com/tlsca/tlsca.$ORG.methodbridge.com-cert.pem
CAPEM=../organizations/peerOrganizations/$ORG.methodbridge.com/ca/ca.$ORG.methodbridge.com-cert.pem
PEERNAME1=peer0
PEERNAME2=peer1

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $PEERNAME1 $PEERNAME2 $P1PORT)" > ../organizations/peerOrganizations/$ORG.methodbridge.com/connection-$ORG.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $PEERNAME1 $PEERNAME2 $P1PORT)" > ../organizations/peerOrganizations/$ORG.methodbridge.com/connection-$ORG.yaml



