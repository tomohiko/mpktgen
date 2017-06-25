#!/bin/sh

modprobe pktgen

usage_exit() {
	echo "Usage: $0 -i IFACE -p DEST_PORT -c CORE DEST_IP"
	echo "example: $0 -i eth0 -p 5000 -c 4 192.168.0.100"
	exit 1
}

#get_pkt_count(){
#	cat /proc/net/dev | grep $interface | tr -s " " | cut -d " " -f 4
#}

while getopts :p:c:i:h OPT
do
	case $OPT in
		i)	interface=$OPTARG
			;;
		c)	use_core=$OPTARG
			;;
		p)	dst_port=$OPTARG
			;;
		h)	usage_exit
			;;
		\?)	echo INVALID OPTION:$OPTARG
			usage_exit
			;;
	esac
done
shift $((OPTIND - 1))
dst_ip=$1

total_cores=`nproc`

if [ $total_cores -lt $use_core ]; then
	echo Too many cores.	
	exit 1
fi

echo "Preparing..."

for ((core=0;core<${use_core};core++))
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

echo "START!!"

echo "start"                     > /proc/net/pktgen/pgctrl&

before_count=`cat /proc/net/dev | grep $interface | tr -s " " | cut -d " " -f 4`

while :;
do
	echo "stop: Ctrl + c"
	now_count=`cat /proc/net/dev | grep $interface | tr -s " " | cut -d " " -f 4`
	echo $before_count:::$now_count
	sleep 1;
	before_count=$now_count
	clear
done
