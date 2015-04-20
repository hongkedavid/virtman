# start-time
curr=$(date +%s);
while [ $curr -lt $1 ]; do curr=$(date +%s); done
i=1000; 
while [ $i -le 9000 ]
do 
    ./port-scanner 10.0.0.42 $i $(($i+1019)) port_scan.out; 
    i=$(($i+1020));
done
