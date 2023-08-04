#!/bin/bash
echo X polling Y
source ./startPollingTest.sh &
sleep 15
source ./removePollingTest.sh &
sleep 2
echo =========================
echo X pushing Y
source ./startPushingTest.sh &
sleep 15
source ./removePushingTest.sh &
sleep 2
echo =========================
echo Y polling X and Y pushing Z
source ./startCombinationTest.sh &
sleep 15
source ./removeCombinationTest.sh &
sleep 2
echo =========================