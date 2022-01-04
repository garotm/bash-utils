sretoolbox 03:04:22 ~/bin/yview/trunk $ var=7; input=$(cat |awk -v variable=${var} -F"\t" '{ print $variable }'|grep -v Node |sort |uniq); printf "\n"; for i in $input; do fping $i; done ;printf "\n";

First Occurrence        Last Occurrence DisplayedAt     OwnedAt Count   Location        Node    Manager Ticket  Summary AutoMessage     Owner   Object
5/13/2012 10:36:18 PM   5/13/2012 10:36:18 PM   5/13/2012 10:37:02 PM   12/31/1969 7:00:00 PM   1       transcolo       cgses115.msg.sp1.yahoo.com    messenger/US             idle_cpu -> Check timed out             Nobody
5/13/2012 10:46:28 PM   5/13/2012 10:46:28 PM   5/13/2012 10:47:02 PM   12/31/1969 7:00:00 PM   1       transcolo       cgses111.msg.sp1.yahoo.com    messenger/US             idle_cpu -> Check timed out             Nobody
5/13/2012 10:46:28 PM   5/13/2012 10:46:28 PM   5/13/2012 10:47:02 PM   12/31/1969 7:00:00 PM   1       transcolo       cgses104.msg.sp1.yahoo.com    messenger/US             idle_cpu -> Check timed out             Nobody
5/13/2012 10:46:28 PM   5/13/2012 10:46:28 PM   5/13/2012 10:47:02 PM   12/31/1969 7:00:00 PM   1       transcolo       cgsrbes106.msg.sp1.yahoo.com  messenger/US             idle_cpu -> Check timed out             Nobody
5/13/2012 10:46:28 PM   5/13/2012 10:46:28 PM   5/13/2012 10:47:02 PM   12/31/1969 7:00:00 PM   1       transcolo       cgsrbes107.msg.sp1.yahoo.com  messenger/US             idle_cpu -> Check timed out             Nobody
5/13/2012 10:36:18 PM   5/13/2012 10:36:18 PM   5/13/2012 10:37:02 PM   12/31/1969 7:00:00 PM   1       transcolo       cgses101.msg.sp1.yahoo.com    messenger/US             idle_cpu -> Check timed out             Nobody
5/13/2012 10:36:18 PM   5/13/2012 10:36:18 PM   5/13/2012 10:37:02 PM   12/31/1969 7:00:00 PM   1       transcolo       cgsrbes108.msg.sp1.yahoo.com  messenger/US             idle_cpu -> Check timed out             Nobody
                                   1                                   2                                   3                                   4     5                   6              "7" in this config

cgses101.msg.sp1.yahoo.com is alive
cgses104.msg.sp1.yahoo.com is alive
cgses111.msg.sp1.yahoo.com is alive
cgses115.msg.sp1.yahoo.com is alive
cgsrbes106.msg.sp1.yahoo.com is alive
cgsrbes107.msg.sp1.yahoo.com is alive
cgsrbes108.msg.sp1.yahoo.com is alive

Get the top  line word count:

input=`cat |grep Node |wc -w`; printf "\n"; for i in $input; do echo $i; done ;printf "\n";

15
