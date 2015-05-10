# tcpdump-file count-flow-entry-output
# filter openflow version, pkt-src-ip, pkt-dst-ip
tcpdump -nnvvXSs 1514 'dst 141.212.108.10 and dst port 6653 and tcp[20:2] = 0x010a and tcp[64:4] = 0x0a000029 and tcp[68:4] = 0x0a00002a' -r $1 > pktin.out;
# verify pkt-in message sent at switch
i=1000;
while [ $i -le 10000 ];
do
     a=$(cat $2 | grep "tp_dst=$i" | wc -l);
     h=$(printf "%04x\n" $i);
     b=$(cat pktin.out | grep " $h " | grep  "0a00 002a\| 05b0 " | wc -l);
     j=1;
     cnt=0;
     while [ $j -le $b ]; do
         s=$(cat tmp | grep " $h " | grep  "0a00 002a\| 05b0 " | head -n$j | tail -n1);
         if [ $(echo $s | grep -b -o "0a00 002a" | wc -l) -gt 0 ]; then
             t1=$(echo $s | grep -b -o "0a00 002a" | cut -d':' -f1);
             s=$(echo $s | sed "s/0a00 002a/xxxx xxxx/1");
             while [ $(echo $s | grep " $h " | wc -l) -gt 0 ]; do
                    t=$(echo $s | grep -b -o " $h " | cut -d':' -f1);
                    t=$(($t+1));
                    if [ $(($t-$t1)) -eq 15 ]; then
                        cnt=$(($cnt+1));
                    fi
                    s=$(echo $s | sed "s/$h/xxxx/1");
             done
         fi
         if [ $(echo $s | grep " $h 05b0 " | wc -l) -gt 0 ]; then
             cnt=$(($cnt+1));
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
