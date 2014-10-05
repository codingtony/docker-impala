#!/bin/bash

su hdfs sh -c "hadoop fs -ls /user/impala" 2> /dev/null
if [[ "$?" != "0" ]]; then
	echo "Creating directories in HDFS for Impala"
	su hdfs sh -c "hadoop fs -mkdir  /user"
	su hdfs sh -c "hadoop fs -chmod 755  /user"
	su hdfs sh -c "hadoop fs -mkdir  /user/impala"
	su hdfs sh -c "hadoop fs -mkdir  /user/hive"
	su hdfs sh -c "hadoop fs -mkdir  /tmp"
	su hdfs sh -c "hadoop fs -chmod 777  /tmp"
	su hdfs sh -c "hadoop fs -chown impala:impala /user/impala"
	su hdfs sh -c "hadoop fs -chown impala:impala /user/hive"
fi

/etc/init.d/impala-catalog start
/etc/init.d/impala-state-store start
/etc/init.d/impala-server start

