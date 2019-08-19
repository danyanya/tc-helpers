#!/bin/sh
#
# Script to add HTB shaper for NATed network (/24)
# Works on OpenWRT
# Could be used for "fairness" bandwidth limit 
# Example: MAX=6 SPEED=1 ./htb_make.sh br-lan
# will set up DOWNLOAD rate 1 mbit to clients with possible ceil 
# up to 6 mbit/s
#

function make_htb() {
        tc qdisc del dev $1 root >/dev/null 2>&1
        tc qdisc add dev $1 root handle 1: htb default 254  >/dev/null 2>&1
        tc class add dev $1 parent 1: classid 1:1 htb rate ${MAX}mbit burst 6k  >/dev/null 2>&1
        for i in $(seq 2 254); do
                tc class add dev $1 parent 1:1 classid 1:${i} htb rate ${SPEED}mbit ceil ${MAX}mbit burst 6k  >/dev/null 2>&1
                tc filter add dev $1 protocol ip u32 match ip dst ${IP}${i} flowid 1:${i}  >/dev/null 2>&1
        done
}

IP=$(ip addr show dev $1 | grep inet | awk '{print $2;}' | cut -d. -f1-3).

MAX=${MAX} SPEED=${SPEED} IP=${IP} make_htb $1

