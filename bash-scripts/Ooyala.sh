#!/usr/local/bin/bash
#: Title        : parallel-xfer
#: Date         : 2013-02-01
#: Author       : Garot Conklin
#: Version      : 1.00
#: Description  : Generalized multi-core leveraging zipper/scp-er
#: Options      : N/A
#: BUG          : N/A
#: Return codes : 0
#:              : 0 = successful
#:              : 1 = failure
#:              :-1 = ambiguous; no execution
#:
function main() {
#:
rhost='name_your_host_here';
#:
cd /var/log/apache2
#:
#: List the dir, dump to parallel, use all available cores w/ 'nice' 
#: throttling/reduced priority and gzip all files (50 in this example).
#: Then pipe it again to parallel to be scp'd to a remote host (no throttling, 
#: this is not nearly as CPU intensive as gzip so speed is optimized here). 
#:
ls *.log |time nice -n10 parallel -j+0 --eta gzip; ls *.gz | parallel -j+0 --eta scp {} $rhost:/home/conklin/test/;
exit 0;
}
printf "%14s$0\n";
main;
#: EOF

################
################
  EXPLAINATION
################
################

If not in the background, the output looks something like this (this is an actual run of the code):

Computers / CPU cores / Max jobs to run
1:local / 8 / 8

Computer:jobs running/jobs completed/%of started jobs/Average seconds to complete
ETA: 1s 0left 0.67avg  local:0/101/100%/0.7s 
351.88user 32.82system 1:08.85elapsed 558%CPU (0avgtext+0avgdata 44240maxresident)k
0inputs+0outputs (0major+111610minor)pagefaults 0swaps

Computers / CPU cores / Max jobs to run
1:local / 8 / 8

133.26user 32.93system 7:34.57elapsed 36%CPU (0avgtext+0avgdata 44304maxresident)k
0inputs+0outputs (0major+360987minor)pagefaults 0swaps

Note worthy is the '-j+0' flag used in the gzip. That might take some additional tuning to optimize based on the deliverable.
Perhaps '-j4' (restricting to only 4 cores (of 8)) in parallel (pardon the pun) would yield a more optimal multi-threaded 
cpu least intensive execution.

Multi-threading validation:
top - 05:29:26 up 168 days, 11:30,  6 users,  load average: 0.46, 0.49, 1.82
Tasks: 239 total,   1 running, 238 sleeping,   0 stopped,   0 zombie
Cpu(s):  3.8%us,  0.8%sy,  0.0%ni, 95.0%id,  0.0%wa,  0.1%hi,  0.3%si,  0.0%st
Mem:   8180956k total,  6215116k used,  1965840k free,    72872k buffers
Swap:  8183800k total,      136k used,  8183664k free,  5231072k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                                                        
23165 conklin   16   0 60572 7560 2624 S  7.0  0.1   0:00.55 ssh                                                             
23167 conklin   15   0 60540 7532 2632 S  6.0  0.1   0:00.47 ssh                                                             
23157 conklin   16   0 60508 7496 2616 S  3.7  0.1   0:00.92 ssh                                                             
23159 conklin   15   0 60668 7660 2632 S  3.7  0.1   0:00.44 ssh                                                             
23161 conklin   15   0 59516 6452 2632 S  3.3  0.1   0:00.66 ssh                                                             
23163 conklin   16   0 59388 6356 2632 S  3.3  0.1   0:00.65 ssh                                                             
23169 conklin   15   0 60540 7500 2632 S  2.7  0.1   0:00.31 ssh                                                             
23166 conklin   18   0 53884 1912 1460 S  0.7  0.0   0:00.04 scp                                                                                                                         
22588 conklin   15   0  100m  10m 1872 S  0.3  0.1   0:00.67 parallel                                                        
23156 conklin   18   0 53884 1912 1460 S  0.3  0.0   0:00.09 scp                                                             
23158 conklin   18   0 53884 1908 1460 S  0.3  0.0   0:00.03 scp                                                             
23162 conklin   18   0 53884 1908 1460 S  0.3  0.0   0:00.06 scp                                                             
23164 conklin   18   0 54776 1908 1460 S  0.3  0.0   0:00.05 scp                                                             
    1 root      15   0 10368  660  564 S  0.0  0.0   0:02.61 init                                                            
    2 root      RT  -5     0    0    0 S  0.0  0.0   0:02.40 migr
