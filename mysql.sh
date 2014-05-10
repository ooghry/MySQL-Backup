#!/bin/bash
user="server username";
pass="server password";
dest="/backup/";
skip="mysql temp test information_schema performance_schema or_exception_database";
skiptable="database_name/exception_table_name"; #for example mydb/log cuase backup all table on mydb except log table.
today="$(date +"%Y_%m_%d")";
dest=${dest}${today}
if [ ! -d "$dest" ]; then
	mkdir $dest
fi
dbs="$(mysql -u $user -p$pass -Bse 'show databases;')"

for db in $dbs
do
	skipdb=-1
	if [ "$skip" != "" ];
	then
		for i in $skip
		do
			[ "$db" == "$i" ] && skipdb=1 || :
		done
	fi
	if [ "$skipdb" == "-1" ];then
		file=${dest}/${db}_$(date +"%H_%M_%S")
		if [ ! -d "$file" ]; then
			mkdir $file
		fi
		tables="$(mysql --skip-column-names -u $user -p$pass $db -e 'show tables;')";
		for table in $tables
		do
			skiptableflag=-1;
			if [ "$skiptable" != "" ];
			then
				for j in $skiptable
				do
					[ "${db}/${table}" == "$j" ] && skiptableflag=1 || :
				done
			fi
			if [ "$skiptableflag" == "-1" ];then
				tmp_file="$file/$table.sql.gz"
				mysqldump -u $user -p$pass $db $table | gzip > $tmp_file
				#sleep 1
			fi
		done		
	fi
done
echo "$today-$(date +"%H_%M_%S") done!";