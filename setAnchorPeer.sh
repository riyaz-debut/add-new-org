#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


CHANNEL_NAME="osqo-channel"

DELAY="5"
TIMEOUT="10"
VERBOSE="false"
COUNTER=1
MAX_RETRY=5


# import utils
. envVar.sh
. configUpdate.sh
export FABRIC_CFG_PATH=${PWD}/./configtx/

# NOTE: this must be run in a CLI container since it requires jq and configtxlator 
createAnchorPeerUpdate() {
  # setPeersGlobals $1
  CORE_PEER_LOCALMSPID="osqoNewOrgMSP"
  infoln "Fetching channel config for channel $CHANNEL_NAME"
  fetchChannelConfig 5 ${CHANNEL_NAME} ${CORE_PEER_LOCALMSPID}config.json

  infoln "Generating anchor peer update transaction for ${ORG} on channel $CHANNEL_NAME"

    HOST="peer0.osqoNewOrg.methodbridge.com"
    PORT=15051
    # HOST=${PEER_NAME}
    # PORT=${PEER_PORT}


  set -x
  # Modify the configuration to append the anchor peer 
  jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json > ${CORE_PEER_LOCALMSPID}modified_config.json
  { set +x; } 2>/dev/null

  # Compute a config update, based on the differences between 
  # {orgmsp}config.json and {orgmsp}modified_config.json, write
  # it as a transaction to {orgmsp}anchors.tx
  createConfigUpdate ${CHANNEL_NAME} ${CORE_PEER_LOCALMSPID}config.json ${CORE_PEER_LOCALMSPID}modified_config.json ${CORE_PEER_LOCALMSPID}anchors.tx
}

updateAnchorPeer() {
  # setPeersGlobals $1
  # echo "PEER_N , ${PEER_N}" 
  CORE_PEER_LOCALMSPID="osqoNewOrgMSP"
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.methodbridge.com -c $CHANNEL_NAME -f ${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA >&.././logs/updateAnchorPeerLogs.txt
  res=$?
  cat .././logs/updateAnchorPeerLogs.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peer set for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
}

createAnchorPeerUpdate 

sleep 10

updateAnchorPeer

