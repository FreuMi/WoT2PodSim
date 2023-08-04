NAMESPACE_1=x
NAMESPACE_2=y
NAMESPACE_3=z

IP_ADDRESS_1='10.10.10.10/24'
IP_ADDRESS_2='10.10.10.20/24'
IP_ADDRESS_3='10.10.10.30/24'

INTERFACE_1=x
INTERFACE_2=y
INTERFACE_3=z

BRIDGE=IOTNETWORKDEMO

# Delete ports from the switch
ovs-vsctl del-port $BRIDGE ovs-$INTERFACE_1
ovs-vsctl del-port $BRIDGE ovs-$INTERFACE_2
ovs-vsctl del-port $BRIDGE ovs-$INTERFACE_3


# Remove network interfaces from namespaces and from the host
ip netns exec $NAMESPACE_1 ip link del $INTERFACE_1
ip netns exec $NAMESPACE_2 ip link del $INTERFACE_2
ip netns exec $NAMESPACE_3 ip link del $INTERFACE_3

# Delete the bridge
ovs-vsctl del-br $BRIDGE

# Delete network namespaces
ip netns del $NAMESPACE_1
ip netns del $NAMESPACE_2
ip netns del $NAMESPACE_3

rm timestampZ.txt
rm timestampY.txt

# Stop all running node programms
pkill node