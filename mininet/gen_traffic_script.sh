curr=$(date +%s);
curr=$(($curr+350)); #50
echo "screen -d -m iperf -s" > start_shuffle.sh;
i=1;
while [ $i -le 40 ];
do
    echo "screen -d -m ./timed_iperf.sh $curr 10.0.0.$i" >> start_shuffle.sh;
    i=$(($i+1));
done
chmod 755 start_shuffle.sh;
echo "screen -d -m ./port_scan.sh $((curr+2))" > start_port_scan.sh; #1
chmod 755 start_port_scan.sh;
