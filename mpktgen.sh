#!/bin/sh

modprobe pktgen

###change here###
use_core=7
dst_ip="192.168.0.100"
dst_port=5000
interface="eth0"
######

total_cores=`nproc`
for ((core=0;core<${total_cores};core++))
do
	echo "rem_device_all"            > /proc/net/pktgen/kpktgend_${core}
done

for ((core=0;core<${use_core};core++))
do
        echo "rem_device_all"                     > /proc/net/pktgen/kpktgend_${core}
		echo "add_device ${interface}@${core}"           > /proc/net/pktgen/kpktgend_${core}
		echo "flag QUEUE_MAP_CPU"                   > /proc/net/pktgen/${interface}@${core}
		echo "count 0"                           > /proc/net/pktgen/${interface}@${core}
        echo "clone_skb 10"                      > /proc/net/pktgen/${interface}@${core}
		echo "pkt_size 60"                       > /proc/net/pktgen/${interface}@${core}
		echo "delay 0"                           > /proc/net/pktgen/${interface}@${core}
		echo "dst ${dst_ip}"                     > /proc/net/pktgen/${interface}@${core}
        echo "udp_dst_min ${dst_port}"            > /proc/net/pktgen/${interface}@${core}
		echo "udp_src_max ${dst_port}"            > /proc/net/pktgen/${interface}@${core}
        echo "udp_src_min ${dst_port}"            > /proc/net/pktgen/${interface}@${core}
        echo "udp_dst_max ${dst_port}"            > /proc/net/pktgen/${interface}@${core}
        echo "burst 8"            > /proc/net/pktgen/${interface}@${core}
done
echo "start"                     > /proc/net/pktgen/pgctrl
