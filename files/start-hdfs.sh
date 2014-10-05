#!/bin/bash

sed -i "s/__HOSTNAME__/$(hostname -i)/" /etc/hadoop/conf/core-site.xml
sed -i "s/__HOSTNAME__/$(hostname -i)/" /etc/impala/conf/core-site.xml
if [[ ! -e /var/lib/hadoop-hdfs/cache/hdfs/dfs/name/current ]]; then
	/etc/init.d/hadoop-hdfs-namenode init
fi
/etc/init.d/hadoop-hdfs-namenode start
/etc/init.d/hadoop-hdfs-datanode start
