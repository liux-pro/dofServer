#!/bin/sh

DNF_DIR="/home/neople"

./ctrl.sh channel start
sleep 10
./ctrl.sh relay start
sleep 10
./ctrl.sh stun start
sleep 10
./ctrl.sh all_common start
sleep 10
./ctrl.sh all_auction start
sleep 10
./ctrl.sh all_point start
sleep 10
./ctrl.sh all_app start
sleep 10
cd ${DNF_DIR}/secsvr/secagent
./zergsvr -t 30 -i 1 -d &
./secagent -i 1 -d &
sleep 5
cd ${DNF_DIR}/secsvr/gunnersvr
./gunnersvr -t 7 -i 1 -d &
sleep 5
cd ${DNF_DIR}
./ctrl.sh game start &
