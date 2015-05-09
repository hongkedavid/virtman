# tcpdump-file count-flow-entry-output
# filter openflow version, pkt-src-ip, pkt-dst-ip
tcpdump -nnvvXSs 1514 'dst 141.212.108.10 and dst port 6653 and tcp[20:2] = 0x010a and tcp[64:4] = 0x0a000029 and tcp[68:4] = 0x0a00002a' -r $1 > pktin.out;
# verify pkt-in message sent at switch
i=1000;
while [ $i -le 10000 ];
do
     a=$(cat $2 | grep "tp_dst=$i" | wc -l);
     h=$(printf "%04x\n" $i);
     b=$(cat $1 | grep " $h " | grep  "0a00 002a\| 05b0 " | wc -l);
     j=1;
     cnt=0;
     while [ $j -le $b ]; do
         t=$(cat tmp | grep " $h " | grep  "0a00 002a\| 05b0 " | head -n$j | tail -n1 | grep -b -o "$h" | cut -d':' -f1);
         if [ $(cat tmp | grep " $h " | grep  "0a00 002a\| 05b0 " | head -n$j | tail -n1 | grep -b -o "0a00 002a" | wc -l) -gt 0 ]; then
             t1=$(cat tmp | grep " $h " | grep  "0a00 002a\| 05b0 " | head -n$j | tail -n1 | grep -b -o "0a00 002a" | cut -d':' -f1);
             if [ $(($t-$t1)) -eq 15 ]; then
                 cnt=$(($cnt+1));
             fi
         fi
         if [ $(cat tmp | grep " $h " | grep  "0a00 002a\| 05b0 " | head -n$j | tail -n1 | grep -b -o " 05b0 " | wc -l) -gt 0 ]; then
             t2=$(cat tmp | grep " $h " | grep  "0a00 002a\| 05b0 " | head -n$j | tail -n1 | grep -b -o "05b0 " | cut -d':' -f1);
             if [ $(($t2-$t)) -eq 5 ]; then
                 cnt=$(($cnt+1));
             fi
         fi
         j=$(($j+1));
     done
     b=$cnt;
     if [ $(($a+$b)) -eq 0 ]; then
        i=$(($i+1));
        continue;
     fi
     c=$(($a*$b));
     if [ $c -eq 0 ]; then
        echo "$i: $a $b $cnt";
     fi
     i=$(($i+1));
done
rm pktin.out
