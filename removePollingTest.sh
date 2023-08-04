NAMESPACE_1=client
NAMESPACE_2=server

IP_ADDRESS_1='10.10.10.10/24'
IP_ADDRESS_2='10.10.10.20/24'

INTERFACE_1=client
INTERFACE_2=server

BRIDGE=IOTNETWORKDEMO

# Delete ports from the switch
ovs-vsctl del-port $BRIDGE ovs-$INTERFACE_1
ovs-vsctl del-port $BRIDGE ovs-$INTERFACE_2

# Remove network interfaces from namespaces and from the host
ip netns exec $NAMESPACE_1 ip link del $INTERFACE_1
ip netns exec $NAMESPACE_2 ip link del $INTERFACE_2

# Delete the bridge
ovs-vsctl del-br $BRIDGE

# Delete network namespaces
ip netns del $NAMESPACE_1
ip netns del $NAMESPACE_2

# Stop all running node programms
pkill node