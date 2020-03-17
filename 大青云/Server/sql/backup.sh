#!/bin/bash
if [ $# != 1 ]; then 
	echo "please input db name" 
	exit 1;
fi
dbname=$1
bkfile=`date '+%Y%m%d'.sql`
mysqldump -uroot -p123456 --opt -d -R $dbname > ./history/$bkfile
