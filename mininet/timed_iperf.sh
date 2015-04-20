# start-time dest-ip
curr=$(date +%s);
while [ $curr -lt $1 ]; do curr=$(date +%s); done
iperf -c $2 -t 20
