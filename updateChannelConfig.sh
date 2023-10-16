#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# This script is designed to be run in the cli container as the
# first step of the EYFN tutorial.  It creates and submits a
# configuration transaction to add org3 to the test network
#
CHANNEL_NAME="osqo-channel"
DELAY="5"
TIMEOUT="10"
VERBOSE="false"
COUNTER=1
MAX_RETRY=5



# imports
. envVar.sh
. configUpdate.sh
. utils.sh

infoln "Creating config transaction to add org3 to network"

# Fetch the config for the channel, writing it to config.json
# fetchChannelConfig 1 ${CHANNEL_NAME} config.json

# Modify the configuration to append the new org
set -x
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"osqoNewOrgMSP":.[1]}}}}}' config.json ../organizations/peerOrganizations/osqoNewOrg.methodbridge.com/osqoNewOrg.json > modified_config.json
{ set +x; } 2>/dev/null

# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to org3_update_in_envelope.pb
createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json osqoNewOrg_update_in_envelope.pb



infoln "Signing config transaction"
signConfigtxAsPeerOrg 1 osqoNewOrg_update_in_envelope.pb

signConfigtxAsPeerOrg 2 osqoNewOrg_update_in_envelope.pb

signConfigtxAsPeerOrg 3 osqoNewOrg_update_in_envelope.pb

sleep 10

setGlobals 1
set -x
peer channel update -f osqoNewOrg_update_in_envelope.pb -c ${CHANNEL_NAME} -o localhost:7050 --ordererTLSHostnameOverride orderer.methodbridge.com --tls --cafile ${ORDERER_CA}
{ set +x; } 2>/dev/null


successln "Config transaction to add osqoNewOrg to network submitted"