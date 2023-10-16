#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# This script is designed to be run in the cli container as the
# second step of the EYFN tutorial. It joins the org3 peers to the
# channel previously setup in the BYFN tutorial and install the
# chaincode as version 2.0 on peer0.org3.
#

CHANNEL_NAME="osqo-channel"
DELAY="5"
TIMEOUT="10"
VERBOSE="false"
COUNTER=1
MAX_RETRY=5


# import environment variables
. envVar.sh

# joinChannel ORG
joinChannel() {
  ORG=$1
  local rc=1
  local COUNTER=1
  ## Sometimes Join takes time, hence retry
  setPeersGlobals $ORG
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b $BLOCKFILE >&.././logs/joinChannelLogs.txt
    res=$?
    { set +x; } 2>/dev/null
    let rc=$res
    COUNTER=$(expr $COUNTER + 1)
	done
	cat .././logs/joinChannelLogs.txt
	verifyResult $res "After $MAX_RETRY attempts,${PEER_NAME} has failed to join channel '$CHANNEL_NAME' "
}



setGlobalsCLI 5
BLOCKFILE="${CHANNEL_NAME}.block"

echo "${PEER0NAME}  and ${ORGNAME}"

echo "Fetching channel config block from orderer..."
set -x
peer channel fetch 0 $BLOCKFILE -o localhost:7050 --ordererTLSHostnameOverride orderer.methodbridge.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA >&.././logs/fetchConfigBlock.txt
res=$?
{ set +x; } 2>/dev/null
cat .././logs/fetchConfigBlock.txt
verifyResult $res "Fetching config block from orderer has failed"

infoln "Joining osqoNewOrg peer0 to the channel..."
joinChannel 51



# sleep 20

infoln "Joining osqoNewOrg peer1 to the channel..."
joinChannel 52



# sleep 30

# infoln "Setting anchor peer for osqoNewOrg..."
# . setAnchorPeer.sh

successln "Channel '$CHANNEL_NAME' joined"
successln "osqoNewOrg peer successfully added to network"
