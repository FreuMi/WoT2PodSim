#!/bin/bash
# RTT in ms
RTT=100

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Create network namespaces
ip netns add $NAMESPACE_1
ip netns add $NAMESPACE_2
ip netns add $NAMESPACE_3


# Starting open vswitch
systemctl start openvswitch-switch
ovs-vsctl add-br $BRIDGE

# Adding interfaces
ip link add $INTERFACE_1 type veth peer name ovs-$INTERFACE_1
ip link set $INTERFACE_1 netns $NAMESPACE_1
ip link add $INTERFACE_2 type veth peer name ovs-$INTERFACE_2
ip link set $INTERFACE_2 netns $NAMESPACE_2
ip link add $INTERFACE_3 type veth peer name ovs-$INTERFACE_3
ip link set $INTERFACE_3 netns $NAMESPACE_3

# Add ports to switch
ovs-vsctl add-port $BRIDGE ovs-$INTERFACE_1
ovs-vsctl add-port $BRIDGE ovs-$INTERFACE_2
ovs-vsctl add-port $BRIDGE ovs-$INTERFACE_3

# Bring up devices
ip link set dev ovs-$INTERFACE_1 up
ip link set dev ovs-$INTERFACE_2 up
ip link set dev ovs-$INTERFACE_3 up

# Configure them
ip netns exec $NAMESPACE_1 ip addr add $IP_ADDRESS_1 dev $INTERFACE_1
ip netns exec $NAMESPACE_2 ip addr add $IP_ADDRESS_2 dev $INTERFACE_2
ip netns exec $NAMESPACE_3 ip addr add $IP_ADDRESS_3 dev $INTERFACE_3
ip netns exec $NAMESPACE_1 ip link set dev $INTERFACE_1 up
ip netns exec $NAMESPACE_2 ip link set dev $INTERFACE_2 up
ip netns exec $NAMESPACE_3 ip link set dev $INTERFACE_3 up


# Add delay
ip netns exec $NAMESPACE_1 tc qdisc add dev $INTERFACE_1 root netem delay $((RTT / 2))ms
ip netns exec $NAMESPACE_2 tc qdisc add dev $INTERFACE_2 root netem delay $((RTT / 2))ms
ip netns exec $NAMESPACE_3 tc qdisc add dev $INTERFACE_3 root netem delay $((RTT / 2))ms

echo "Setup Finished..."
ip netns exec $NAMESPACE_2 ping -c 3 10.10.10.10
ip netns exec $NAMESPACE_2 ping -c 3 10.10.10.30


nvm use 16

node --version

# Start X
ip netns exec $NAMESPACE_1 node ./Combination/x.js $IP_ADDRESS_1 &

sleep 2

# Start Z
ip netns exec $NAMESPACE_3 node ./Combination/z.js $IP_ADDRESS_3 &

sleep 2

# Start Y
ip netns exec $NAMESPACE_2 node ./Combination/y.js $IP_ADDRESS_1 $IP_ADDRESS_3 &

sleep 2

# Wait all timestamps are written
file="timestampY.txt"
line_count=$(wc -l < "$file")
# count the lines
while (( line_count != 1 )); do
    sleep 1  # pause for 1 second
    line_count=$(wc -l < "$file")
done
timestampY=$(head -n 1 timestampY.txt)

file="timestampZ.txt"
line_count=$(wc -l < "$file")
# count the lines
while (( line_count < 1 )); do
    sleep 1  # pause for 1 second
    line_count=$(wc -l < "$file")
done
timestampZ=$(head -n 1 timestampZ.txt)
echo total runtime $((timestampZ - timestampY))