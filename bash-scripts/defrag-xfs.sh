#!/bin/bash
# Purpose: To check fragmentation on XFS with xfs_db and run xfs_fsr on XFS mount points that
# are above a specific fragmentation threshold.
#
# What is xfs_db? Use 'man xfs_db' to find out.
# What is xfs_fsr? Use 'man xfs_fsr' to find out.
#
# Any busy files, such as open logs on /var/log, will be skipped. To defragment logs one should
# wrap this script with another script to stop and restart logging. Or, even better, write
# one's own script just for defragmentation of the logs.
#
# Warranty: NONE. Use at your own discretion and be aware that data loss is on your head if
# you choose to use this script.
#
# License: GPL 2.0 http://www.gnu.org/licenses/gpl-2.0.html
#
# Suggested Usage: crontab file for root
# 0 0 * * * /root/bin/chkxfsfrag # Run at midnight
#
# DO NOT ALTER HEADER FROM THIS LINE UP.
#
e='/bin/echo -e'                                # Use the echo command, not built-in.
xfsfsr=/sbin/xfs_fsr                            # Set variable with the path to xfs_fsr.
xfsdb=/sbin/xfs_db                              # Set variable with the path to xfs_db.
pctmax=0                                        # Set maxiumum frag percent needed for defrag.
                                                # This is zero here for testing purposes only
                                                # a higher number should be used in production.
array=$(df -T|grep xfs|cut -f 1 --delim=" ")     # Array of all XFS file systems.
for i in ${array[@]};
do
        percentage=$($xfsdb -c frag -r ${i}|cut -f 7 --delim=" ")
        percent2=$($e $percentage|cut -f 1 --delim=.)
        if [ "$percent2" -gt "$pctmax" ]
        then
                $e "${i} is $percentage fragmented. Running defragment on ${i}."
                # Only uncomment one of the following two lines.
                #$xfsfsr -v ${i}        # Uncomment for verbose defrag.
                #$xfsfsr ${i}           # Uncomment for quiet defrag.
        else
                $e "${i}\t$percent2 is not above fragmentation threshold of $pctmax."
        fi
done
exit 0