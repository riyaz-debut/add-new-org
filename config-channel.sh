CHANNEL_NAME="osqo-channel"
DELAY="5"
TIMEOUT="10"
VERBOSE="false"
COUNTER=1
MAX_RETRY=5


sleep 10 

echo "############################################"
echo "UPDATE CHANNEL CONFIG"
echo "############################################"

# Use the CLI container to create the configuration transaction needed to add
#   osqoNewOrg to the network
  infoln "Generating and submitting config tx to add osqoNewOrg"
  # docker exec cli ./updateChannelConfig.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  ./updateChannelConfig.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    fatalln "ERROR !!!! Unable to create config tx"
  fi

    sleep 10

  infoln "Joining osqoNewOrg peers to network"
  ./joinChannel.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    fatalln "ERROR !!!! Unable to join osqoNewOrg peers to network"
  fi
