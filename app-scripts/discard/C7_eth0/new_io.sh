#！/bin/bash
inet_byte() {
 for i in `ls /sys/class/net/`; do
  j=`tr -d - <<< $i`
#  let "${i}_rx${1} = `cat /sys/class/net/$i/statistics/rx_bytes`"
  eval ${j}_rx${1}=`cat /sys/class/net/$i/statistics/rx_bytes`
#  let "${i}_tx${1} = `cat /sys/class/net/$i/statistics/tx_bytes`"
  eval ${j}_tx${1}=`cat /sys/class/net/$i/statistics/tx_bytes`
 done
}
eva() {
 ethname=`tr -d - <<< $1`
 a1=`eval echo '$'{${ethname}_rx1}`
 a2=`eval echo '$'{${ethname}_rx2}`
 b1=`eval echo '$'{${ethname}_tx1}`
 b2=`eval echo '$'{${ethname}_tx2}`
 tol1=$(($a1+$b1))
 tol2=$(($a2+$b2))
 #echo $1 $a1 $a2 $b1 $b2 $tol1 $tol2
 rxkB=$(echo $a2 $a1 | awk '{ printf "%0.2f",($1-$2)/1024 }')
 txkB=$(echo $b2 $b1 | awk '{ printf "%0.2f",($1-$2)/1024 }')
 TolkB=$(echo $tol2 $tol1 | awk '{ printf "%0.2f" ,($1-$2)/1024 }')
 echo -e "$1\t\t$rxkB\t$txkB\t$TolkB"
}
while true; do
 sleep 2
 clear
 awk 'BEGIN {print "interface\trxKB\ttxKB\tTotalKB\n==========================================";}'
 inet_byte 1
 sleep 1
 inet_byte 2
 for i in `ls /sys/class/net/`; do
  eva $i
 done
done
