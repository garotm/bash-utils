parallel.sh

[conklin@sretoolbox]$ ls *.log |time parallel -j+0 --eta gzip; ls

Computers / CPU cores / Max jobs to run
1:local / 8 / 8

Computer:jobs running/jobs completed/%of started jobs/Average seconds to complete
ETA: 1s 0left 0.67avg  local:0/101/100%/0.7s  
351.88user 32.82system 1:08.85elapsed 558%CPU (0avgtext+0avgdata 44240maxresident)k
0inputs+0outputs (0major+111610minor)pagefaults 0swaps
apache.100.log.gz  apache.25.log.gz  apache.40.log.gz  apache.56.log.gz  apache.71.log.gz  apache.87.log.gz
apache.10.log.gz   apache.26.log.gz  apache.41.log.gz  apache.57.log.gz  apache.72.log.gz  apache.88.log.gz
apache.11.log.gz   apache.27.log.gz  apache.42.log.gz  apache.58.log.gz  apache.73.log.gz  apache.89.log.gz
apache.12.log.gz   apache.28.log.gz  apache.43.log.gz  apache.59.log.gz  apache.74.log.gz  apache.8.log.gz
apache.13.log.gz   apache.29.log.gz  apache.44.log.gz  apache.5.log.gz	 apache.75.log.gz  apache.90.log.gz
apache.14.log.gz   apache.2.log.gz   apache.45.log.gz  apache.60.log.gz  apache.76.log.gz  apache.91.log.gz
apache.15.log.gz   apache.30.log.gz  apache.46.log.gz  apache.61.log.gz  apache.77.log.gz  apache.92.log.gz
apache.16.log.gz   apache.31.log.gz  apache.47.log.gz  apache.62.log.gz  apache.78.log.gz  apache.93.log.gz
apache.17.log.gz   apache.32.log.gz  apache.48.log.gz  apache.63.log.gz  apache.79.log.gz  apache.94.log.gz
apache.18.log.gz   apache.33.log.gz  apache.49.log.gz  apache.64.log.gz  apache.7.log.gz   apache.95.log.gz
apache.19.log.gz   apache.34.log.gz  apache.4.log.gz   apache.65.log.gz  apache.80.log.gz  apache.96.log.gz
apache.1.log.gz    apache.35.log.gz  apache.50.log.gz  apache.66.log.gz  apache.81.log.gz  apache.97.log.gz
apache.20.log.gz   apache.36.log.gz  apache.51.log.gz  apache.67.log.gz  apache.82.log.gz  apache.98.log.gz
apache.21.log.gz   apache.37.log.gz  apache.52.log.gz  apache.68.log.gz  apache.83.log.gz  apache.99.log.gz
apache.22.log.gz   apache.38.log.gz  apache.53.log.gz  apache.69.log.gz  apache.84.log.gz  apache.9.log.gz
apache.23.log.gz   apache.39.log.gz  apache.54.log.gz  apache.6.log.gz	 apache.85.log.gz  apache.log.gz
apache.24.log.gz   apache.3.log.gz   apache.55.log.gz  apache.70.log.gz  apache.86.log.gz

[conklin@sretoolbox]$ ls *.gz |time parallel -j+0 --eta gunzip; ls

Computers / CPU cores / Max jobs to run
1:local / 8 / 8

Computer:jobs running/jobs completed/%of started jobs/Average seconds to complete
ETA: 0s 0left 0.51avg  local:0/101/100%/0.5s  
45.93user 34.21system 0:52.62elapsed 152%CPU (0avgtext+0avgdata 44240maxresident)k
0inputs+0outputs (0major+109891minor)pagefaults 0swaps
apache.100.log	apache.21.log  apache.33.log  apache.45.log  apache.57.log  apache.69.log  apache.80.log  apache.92.log
apache.10.log	apache.22.log  apache.34.log  apache.46.log  apache.58.log  apache.6.log   apache.81.log  apache.93.log
apache.11.log	apache.23.log  apache.35.log  apache.47.log  apache.59.log  apache.70.log  apache.82.log  apache.94.log
apache.12.log	apache.24.log  apache.36.log  apache.48.log  apache.5.log   apache.71.log  apache.83.log  apache.95.log
apache.13.log	apache.25.log  apache.37.log  apache.49.log  apache.60.log  apache.72.log  apache.84.log  apache.96.log
apache.14.log	apache.26.log  apache.38.log  apache.4.log   apache.61.log  apache.73.log  apache.85.log  apache.97.log
apache.15.log	apache.27.log  apache.39.log  apache.50.log  apache.62.log  apache.74.log  apache.86.log  apache.98.log
apache.16.log	apache.28.log  apache.3.log   apache.51.log  apache.63.log  apache.75.log  apache.87.log  apache.99.log
apache.17.log	apache.29.log  apache.40.log  apache.52.log  apache.64.log  apache.76.log  apache.88.log  apache.9.log
apache.18.log	apache.2.log   apache.41.log  apache.53.log  apache.65.log  apache.77.log  apache.89.log  apache.log
apache.19.log	apache.30.log  apache.42.log  apache.54.log  apache.66.log  apache.78.log  apache.8.log
apache.1.log	apache.31.log  apache.43.log  apache.55.log  apache.67.log  apache.79.log  apache.90.log
apache.20.log	apache.32.log  apache.44.log  apache.56.log  apache.68.log  apache.7.log   apache.91.log

-- with 'nice'

Computers / CPU cores / Max jobs to run
1:local / 8 / 8

Computer:jobs running/jobs completed/%of started jobs/Average seconds to complete
ETA: 1s 0left 0.67avg  local:0/101/100%/0.7s  
351.88user 32.82system 1:08.85elapsed 558%CPU (0avgtext+0avgdata 44240maxresident)k
0inputs+0outputs (0major+111610minor)pagefaults 0swaps

ls *.log |time nice -n10 parallel -j+0 --eta gzip | parallel -j+0 --eta scp {} laypurple-dl.bf1oc.corp.yahoo.com:/home/conklin/test/



133.26user 32.93system 7:34.57elapsed 36%CPU (0avgtext+0avgdata 44304maxresident)k
0inputs+0outputs (0major+360987minor)pagefaults 0swaps


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




