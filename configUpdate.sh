CHANNEL_NAME="osqo-channel"
DELAY="5"
TIMEOUT="10"
VERBOSE="false"
COUNTER=1
MAX_RETRY=5



. envVar.sh
../scripts/utils.sh


export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../organizations/ordererOrganizations/methodbridge.com/orderers/orderer.methodbridge.com/msp/tlscacerts/tlsca.methodbridge.com-cert.pem
export PEER0_osqoNewOrg_CA=${PWD}/../organizations/peerOrganizations/osqo.methodbridge.com/peers/peer0.osqo.example.com/tls/ca.crt


echo "############################################"
echo "UPDATE CHANNEL CONFIG"
echo "############################################"

fetchChannelConfig() {

  echo "############################################"
  echo "FETCH CHANNEL CONFIG" $1
  echo "############################################"
  ORG=$1
  CHANNEL=$2
  OUTPUT=$3


    # export CORE_PEER_LOCALMSPID="osqoNewOrgMSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_osqoNewOrg_CA
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/osqo.methodbridge.com/users/Admin@osqo.methodbridge.com/msp
    # export CORE_PEER_ADDRESS=localhost:15051

  setGlobals $ORG
  echo "#######################################"
  echo $PEER0NAME
  echo "########################################"

  infoln "Fetching the most recent configuration block for the channel"
  set -x
  peer channel fetch config config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.methodbridge.com -c $CHANNEL --tls --cafile $ORDERER_CA
  { set +x; } 2>/dev/null

  infoln "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  { set +x; } 2>/dev/null
}



createConfigUpdate() {
  echo "############################################"
  echo "CREATE CONFIG UPDATE"
  echo "############################################"
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb >config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${OUTPUT}"
  { set +x; } 2>/dev/null
}

# createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json osqoNewOrg_update_in_envelope.pb



# Set the peerOrg admin of an org and sign the config update
signConfigtxAsPeerOrg() {
  ORG=$1
  CONFIGTXFILE=$2
  setGlobals $ORG
  set -x
  peer channel signconfigtx -f "${CONFIGTXFILE}"
  { set +x; } 2>/dev/null
}




