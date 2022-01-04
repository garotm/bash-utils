/home/y/sbin/find_wales
#!/bin/bash

WD=/home/y/tmp
OUT=/home/y/tmp/slow_$$.out
TMP_OUT=${WD}/results.out

if [ $# -eq 0 ]
then
	sudo mysqldumpslow -a /home/y/logs/mysql/mysqld-slow.log > ${OUT}
else
	IN_FILE=${1}
	if [ ! -f ${IN_FILE} ]
	then
		printf "File ${IN_FILE} not found!!\n"
		exit
	fi
	sudo mysqldumpslow -a ${IN_FILE} > ${OUT}
fi

IN=${OUT}

if [ -f ${TMP_OUT} ]
then
	rm -rf ${TMP_OUT}
fi

SQL_CNT=`grep "  /\*" ${IN} | wc -l`

get_coll_details()
{
	COLUMN=${1}
	grep -o -E -- "${COLUMN}=\w+" ${IN} | sed "s/${COLUMN}=//g" > ${WD}/${COLUMN}.out

	# Get info for ${COLUMN}
	sort -u -o ${WD}/${COLUMN}.out ${WD}/${COLUMN}.out

	while read ID
	do
		CNT=`grep -c "${ID}" ${IN}`
		PCT=`echo "scale=5;${CNT} / ${SQL_CNT} * 100" | bc`
		printf "%15s %-15s %15s %-15s\n" ${PCT} ${ID} ${CNT} ${COLUMN} >> ${TMP_OUT}
	done < ${WD}/${COLUMN}.out
	rm -rf ${WD}/${COLUMN}.out

};

print_output()
{
	if [ -f ${TMP_OUT} ]
	then
		printf "Get most active user_id's, accountid's and photo_owner_id's from the latest slow log\n"
		printf "Total queries examined: ${SQL_CNT}\n\n"
		printf "%15s %-15s %15s %-15s\n" "Percentage" "ID" "Count" "Type"
		printf "==============================================================\n"
		sort -r -n -k1 ${TMP_OUT}  |head -30 > ${WD}/results_$$.out
		cat ${WD}/results_$$.out
	else
		printf "\nNo output file found. There are possibly no slow queries at the moment\n\n"
	fi
};

cleanup()
{
	# Cleanup
	if [ -f ${OUT} ]
	then
		rm -rf ${OUT}
	fi

	if [ -f ${WD}/results.out ]
	then
		rm -rf ${WD}/results.out
	fi
};

for COL in user_id accountid photo_owner_id tag_id group_id
do
	get_coll_details ${COL}
done

print_output
cleanup