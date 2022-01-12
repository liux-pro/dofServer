#!/bin/sh

./ctrl.sh game stop
killall -9 zergsvr
killall -9 secagent
killall -9 gunnersvr
./ctrl.sh all_app stop
sleep 10
./ctrl.sh all_point stop
sleep 10
./ctrl.sh all_auction stop
sleep 10
./ctrl.sh all_common stop
sleep 10
./ctrl.sh stun stop
sleep 10
./ctrl.sh relay stop
sleep 10
./ctrl.sh channel stop
