#!/bin/bash
# RTT in ms
RTT=100

NAMESPACE_1=client
NAMESPACE_2=server

IP_ADDRESS_1='10.10.10.10/24'
IP_ADDRESS_2='10.10.10.20/24'

INTERFACE_1=client
INTERFACE_2=server

BRIDGE=IOTNETWORKDEMO

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Create network namespaces
ip netns add $NAMESPACE_1
ip netns add $NAMESPACE_2

# Starting open vswitch
systemctl start openvswitch-switch
ovs-vsctl add-br $BRIDGE

# Adding interfaces
ip link add $INTERFACE_1 type veth peer name ovs-$INTERFACE_1
ip link set $INTERFACE_1 netns $NAMESPACE_1
ip link add $INTERFACE_2 type veth peer name ovs-$INTERFACE_2
ip link set $INTERFACE_2 netns $NAMESPACE_2

# Add ports to switch
ovs-vsctl add-port $BRIDGE ovs-$INTERFACE_1
ovs-vsctl add-port $BRIDGE ovs-$INTERFACE_2

# Bring up devices
ip link set dev ovs-$INTERFACE_1 up
ip link set dev ovs-$INTERFACE_2 up

# Configure them
ip netns exec $NAMESPACE_1 ip addr add $IP_ADDRESS_1 dev $INTERFACE_1
ip netns exec $NAMESPACE_2 ip addr add $IP_ADDRESS_2 dev $INTERFACE_2
ip netns exec $NAMESPACE_1 ip link set dev $INTERFACE_1 up
ip netns exec $NAMESPACE_2 ip link set dev $INTERFACE_2 up


# Add delay
ip netns exec $NAMESPACE_1 tc qdisc add dev $INTERFACE_1 root netem delay $((RTT / 2))ms
ip netns exec $NAMESPACE_2 tc qdisc add dev $INTERFACE_2 root netem delay $((RTT / 2))ms

echo "Setup Finished..."
ip netns exec $NAMESPACE_1 ping -c 3 10.10.10.20

nvm use 16

node --version

# Start Server
ip netns exec $NAMESPACE_2 node ./Polling/server.js $IP_ADDRESS_2 &

sleep 2

# Start Client
ip netns exec $NAMESPACE_1 node ./Polling/client.js $IP_ADDRESS_2
