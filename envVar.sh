#!/bin/bash

# imports
. utils.sh

echo "INSIDE ENV VAR file"

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../organizations/ordererOrganizations/methodbridge.com/orderers/orderer.methodbridge.com/msp/tlscacerts/tlsca.methodbridge.com-cert.pem
export PEER0_OSQO_CA=${PWD}/../organizations/peerOrganizations/osqo.methodbridge.com/peers/peer0.osqo.methodbridge.com/tls/ca.crt
export PEER1_OSQO_CA=${PWD}/../organizations/peerOrganizations/osqo.methodbridge.com/peers/peer1.osqo.methodbridge.com/tls/ca.crt
export PEER0_BCP_CA=${PWD}/../organizations/peerOrganizations/bcp.methodbridge.com/peers/peer0.bcp.methodbridge.com/tls/ca.crt
export PEER1_BCP_CA=${PWD}/../organizations/peerOrganizations/bcp.methodbridge.com/peers/peer1.bcp.methodbridge.com/tls/ca.crt
export PEER0_ESP_CA=${PWD}/../organizations/peerOrganizations/esp.methodbridge.com/peers/peer0.esp.methodbridge.com/tls/ca.crt
export PEER1_ESP_CA=${PWD}/../organizations/peerOrganizations/esp.methodbridge.com/peers/peer1.esp.methodbridge.com/tls/ca.crt
export PEER0_BROKER_CA=${PWD}/../organizations/peerOrganizations/broker.methodbridge.com/peers/peer0.broker.methodbridge.com/tls/ca.crt
export PEER1_BROKER_CA=${PWD}/../organizations/peerOrganizations/broker.methodbridge.com/peers/peer1.broker.methodbridge.com/tls/ca.crt
export PEER0_osqoNewOrg_CA=${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/peers/peer0.osqoNewOrg.methodbridge.com/tls/ca.crt

export PEER1_osqoNewOrg_CA=${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/peers/peer1.osqoNewOrg.methodbridge.com/tls/ca.crt


# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    PEER0NAME=peer0.osqo.methodbridge.com
    ORGNAME=OSQO
    export CORE_PEER_LOCALMSPID="osqoMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OSQO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/osqo.methodbridge.com/users/Admin@osqo.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG -eq 2 ]; then
  PEER0NAME=peer0.bcp.methodbridge.com
  ORGNAME=BCP
    export CORE_PEER_LOCALMSPID="bcpMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BCP_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/bcp.methodbridge.com/users/Admin@bcp.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG -eq 3 ]; then
   PEER0NAME=peer0.esp.methodbridge.com
   ORGNAME=ESP           
    export CORE_PEER_LOCALMSPID="espMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ESP_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/esp.methodbridge.com/users/Admin@esp.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:11051  
  elif [ $USING_ORG -eq 4 ]; then
   PEER0NAME=peer0.broker.methodbridge.com
   ORGNAME=BROKER
    export CORE_PEER_LOCALMSPID="brokerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BROKER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/broker.methodbridge.com/users/Admin@broker.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:13051
  elif [ $USING_ORG -eq 5 ]; then
   PEER0NAME=peer0.osqoNewOrg.methodbridge.com
   ORGNAME=osqoNewOrg
    export CORE_PEER_LOCALMSPID="osqoNewOrgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_osqoNewOrg_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/users/Admin@osqoNewOrg.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:15051    
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}


setPeersGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 11 ]; then
    PEER_NAME=peer0.osqo.methodbridge.com
    export CORE_PEER_LOCALMSPID="osqoMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OSQO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/osqo.methodbridge.com/users/Admin@osqo.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG -eq 12 ]; then
  PEER_NAME=peer1.osqo.methodbridge.com
    export CORE_PEER_LOCALMSPID="osqoMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_OSQO_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/osqo.methodbridge.com/users/Admin@osqo.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:6051
  elif [ $USING_ORG -eq 21 ]; then
  PEER_NAME=peer0.bcp.methodbridge.com
    export CORE_PEER_LOCALMSPID="bcpMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BCP_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/bcp.methodbridge.com/users/Admin@bcp.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG -eq 22 ]; then
  PEER_NAME=peer1.bcp.methodbridge.com
    export CORE_PEER_LOCALMSPID="bcpMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_BCP_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/bcp.methodbridge.com/users/Admin@bcp.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:10051  
  elif [ $USING_ORG -eq 31 ]; then
  PEER_NAME=peer0.esp
    export CORE_PEER_LOCALMSPID="espMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ESP_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/esp.methodbridge.com/users/Admin@esp.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  elif [ $USING_ORG -eq 32 ]; then
  PEER_NAME=peer1.esp.methodbridge.com
    export CORE_PEER_LOCALMSPID="espMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ESP_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/esp.methodbridge.com/users/Admin@esp.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:12051
  elif [ $USING_ORG -eq 41 ]; then
  PEER_NAME=peer0.broker.methodbridge.com
    export CORE_PEER_LOCALMSPID="brokerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BROKER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/broker.methodbridge.com/users/Admin@broker.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:13051
  elif [ $USING_ORG -eq 42 ]; then
    PEER_NAME=peer1.broker.methodbridge.com
    export CORE_PEER_LOCALMSPID="brokerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_BROKER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/broker.methodbridge.com/users/Admin@broker.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:14051  
  elif [ $USING_ORG -eq 51 ]; then
  PEER_N=0
    PEER_NAME=peer0.osqoNewOrg.methodbridge.com
    export CORE_PEER_LOCALMSPID="osqoNewOrgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_osqoNewOrg_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/users/Admin@osqoNewOrg.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:15051 
    PEER_PORT=15051 
  elif [ $USING_ORG -eq 52 ]; then
    PEER_N=1
    PEER_NAME=peer1.osqoNewOrg.methodbridge.com
    export CORE_PEER_LOCALMSPID="osqoNewOrgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_osqoNewOrg_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/users/Admin@osqoNewOrg.methodbridge.com/msp
    export CORE_PEER_ADDRESS=localhost:16051   
    PEER_PORT=16051 
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.osqo.methodbridge.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.bcp.methodbridge.com:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.esp.methodbridge.com:11051
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_ADDRESS=peer0.broker.methodbridge.com:13051  
  elif [ $USING_ORG -eq 5 ]; then
    export CORE_PEER_ADDRESS=peer0.osqoNewOrg.methodbridge.com:15051    
  else
    errorln "ORG Unknown"
  fi
}

# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do

    setGlobals $1
    PEER=$P                                                                                                                                                         

    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$CORE_PEER_TLS_ROOTCERT_FILE")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    shift 
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"

}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
