export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/./configtx
export VERBOSE=false

CA_IMAGETAG="latest"
IMAGETAG="latest"
SYS_CHANNEL="system-channel"
CHANNEL_NAME="osqo-channel"
DELAY="5"
TIMEOUT="10"
VERBOSE="false"
COUNTER=1
MAX_RETRY=5

ORG="osqoNewOrg"


../scripts/utils.sh
. utils.sh


# certificate authorities compose file for OSQO
COMPOSE_FILE_CA_OSQONEWORG=./docker-compose-ca/osqoNewOrg/compose/docker-compose-ca.yaml

docker-compose -f $COMPOSE_FILE_CA_OSQONEWORG up -d
sleep 10

  # If the test network is not up, abort
  # if [ ! -d .././organizations/ordererOrganizations ]; then
  #   fatalln "ERROR: orderer organization did not found"
  # fi


  #     # generate artifacts if they don't exist
  # if [ ! -d ../organizations/peerOrganizations/osqoNewOrg.methodbridge.com ]; then
  #   generateOrg3
  #   generateOrg3Definition
  # fi



export FABRIC_CFG_PATH=${PWD}/../configtx
export VERBOSE=false


function enrollOrgCaAdmin {
	echo "=================================================="
    echo "ENROLL CA for "$1 "for" $2 
  echo "=================================================="
	mkdir -p ${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/
    export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/

     set -x
    fabric-ca-client enroll -u https://admin:adminpw@localhost:$2 --caname ca-$1 --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
    { set +x; } 2>/dev/null



    # Writing config.yaml file for Orgs
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/localhost-12054-ca-osqoNewOrg.pem
      OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
      Certificate: cacerts/localhost-12054-ca-osqoNewOrg.pem
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/localhost-12054-ca-osqoNewOrg.pem
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/localhost-12054-ca-osqoNewOrg.pem
      OrganizationalUnitIdentifier: orderer' >${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/msp/config.yaml

}

enrollOrgCaAdmin osqoNewOrg 12054
#




# ================================ REGISTER PEERS FOR ORG=========================================

function RegisterPeers(){
  echo "=================================================="
  echo "Register peer0 for "$1
  echo "=================================================="

  export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/

  set -x
  fabric-ca-client register --caname ca-$1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "=================================================="
  echo "Register peer1 for "$1
  echo "=================================================="
  set -x
  fabric-ca-client register --caname ca-$1 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null


}

RegisterPeers $ORG


# ================================= REGISTER USERS FOR ORG ==========================================

function RegisterUser(){
  echo "=================================================="
  echo "Register user for "$1
  echo "=================================================="

  export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/

  set -x
  fabric-ca-client register --caname ca-$1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null

}

RegisterUser $ORG



# ================================ REGISTER ADMIN FOR ORG =============================================

function RegisterOrgAdmin(){
  echo "=================================================="
  echo "Register Admin for "$1
  echo "=================================================="

  export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/

  set -x
  fabric-ca-client register --caname ca-$1 --id.name $1admin --id.secret $1adminpw --id.type admin --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null

}

RegisterOrgAdmin $ORG




# ================================ GENERATE MSP PEERS FOR ORGS =======================================

function GenerateMsp(){
  echo "=================================================="
  echo "Generate MSP for peer0 "$1
  echo "=================================================="

  export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/

  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:$2 --caname ca-$1 -M ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/msp --csr.hosts peer0.$1.methodbridge.com --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/
  

  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/config.yaml ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/msp/config.yaml

  echo "=================================================="
  echo "Generate MSP for peer1 "$1
  echo "=================================================="

  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:$2 --caname ca-$1 -M ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/msp --csr.hosts peer1.$1.methodbridge.com --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/config.yaml ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/msp/config.yaml


  echo "=================================================="
  echo "Generate MSP for USER "$1
  echo "=================================================="

  # //adding tls-cert into users folder
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:$2 --caname ca-$1 -M ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/users/User1@$1.methodbridge.com/msp --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null

  # copying config.yaml into users msp folder
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/config.yaml ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/users/User1@$1.methodbridge.com/msp/config.yaml


  echo "=================================================="
  echo "Generate MSP for ORG ADMIN "$1
  echo "=================================================="

  # adding tls-cert into admin folder
  set -x
  fabric-ca-client enroll -u https://$1admin:$1adminpw@localhost:$2 --caname ca-$1 -M ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/users/Admin@$1.methodbridge.com/msp --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null

  # copying config.yaml into admin msp folder
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/config.yaml ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/users/Admin@$1.methodbridge.com/msp/config.yaml


}

GenerateMsp $ORG 12054



function GeneratePeerTLS(){
  echo "=================================================="
  echo "Generate TLS for peer0 "$1
  echo "=================================================="
  
  # creating tls
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:$2 --caname ca-$1 -M ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls --enrollment.profile tls --csr.hosts peer0.$1.methodbridge.com --csr.hosts localhost --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/ca.crt
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/signcerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/server.crt
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/keystore/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/server.key


  mkdir -p ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/tlscacerts
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/tlsca
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/tlsca/tlsca.$1.methodbridge.com-cert.pem

  mkdir -p ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/ca
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer0.$1.methodbridge.com/msp/cacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/ca/ca.$1.methodbridge.com-cert.pem

  echo "=================================================="
  echo "Generate TLS for peer1 "$1
  echo "=================================================="

  # creating tls
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:$2 --caname ca-$1 -M ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls --enrollment.profile tls --csr.hosts peer1.$1.methodbridge.com --csr.hosts localhost --tls.certfiles ${PWD}/./docker-compose-ca/$1/fabric-ca/tls-cert.pem
  { set +x; } 2>/dev/null


  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/ca.crt
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/signcerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/server.crt
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/keystore/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/server.key



  mkdir -p ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/tlscacerts
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/tlsca
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/tlsca/tlsca.$1.methodbridge.com-cert.pem

  mkdir -p ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/ca
  cp ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/peers/peer1.$1.methodbridge.com/msp/cacerts/* ${PWD}/../organizations/peerOrganizations/$1.methodbridge.com/ca/ca.$1.methodbridge.com-cert.pem
}

GeneratePeerTLS $ORG 12054



sleep 5

	echo "=================================================="
    echo "GENERATE CCP FOR NEW ORG"
    echo "=================================================="


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

export FABRIC_CFG_PATH=$PWD/./configtx/
  set -x
  configtxgen -printOrg osqoNewOrgMSP > ${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/osqoNewOrg.json
  res=$?
  { set +x; } 2>/dev/null
   if [ $res -ne 0 ]; then
    fatalln "Failed to generate Org3 organization definition..."
  fi


sleep 10

echo "############################################"
echo "PEER NODES UP"
echo "############################################"

docker-compose -f ./docker-compose-network/docker-compose.yaml up -d 2>&1
if [ $? -ne 0 ]; then
  fatalln "ERROR !!!! Unable to start osqoNewOrg network"
fi


sleep 10

./config-channel.sh

sleep 10

./setAnchorPeer.sh

