#!/usr/local/bin/bash
#: Title        : load_one
#: Date         : 2013-05-09
#: Author       : Garot Conklin
#: Version      : 0.0.1
#: Description  : Resident netmon ganglia load_one metric check
#: Options      : None
#: BUG(s)       : [bug 5481476, 6017746, 6262157] 
#: Return codes : 2
#:              : 0   = successful
#:              : 1   = failure
#:
TIME=$(date +%s)
RRDRES=900
DIR=$(find /home/y/var/ganglia/rrds/ -name load_one.rrd |grep -v flickr |grep [A-Z][A-Z])
DIR_CUT=$(for z in $DIR; do echo $z |awk -F/ '{print $7}'; done)
for c in $DIR_CUT; do
        printf '\n\e[1;35m%-6s\e[m\n' "$c"
        for i in AVERAGE MAX; do
                printf "$i\n";
                for sig in h d w m; do
                        if [ $sig = h ]; then
                                printf '\e[1;30m%-6s\e[m\n' " HOURLY:"
                        elif [ $sig = d ]; then
                                printf '\e[1;31m%-6s\e[m\n' " DAILY:"
                        elif [ $sig = w ]; then
                                printf '\e[1;32m%-6s\e[m\n' " WEEKLY:"
                        else
                                printf '\e[1;33m%-6s\e[m\n' " MONTHLY:"
                        fi
                        for d in $DIR; do
                                printf " %.2f\n" $(rrdtool fetch $d $i -r $RRDRES -s -1$sig |grep "+01" |awk '{print $2}' |sed 's/[^0-9.]*//g' |sort -nr |uniq |head -2)
                        done
                done
        done
done