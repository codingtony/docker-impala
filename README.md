Dockerfile for Standalone Cloudera Impala Server 1.4
==
This image is based on CDH5 and runs on Ubuntu 12.04 precise.
It runs a single node cluster with a datanode and a namenode running on the same machine.

It also run impala server, impala state store and impala catalog

Don't expect great performance. But it provides enough functionality to test impala queries without disturbing the cluster.

It's great for developpers that want to test their queries before running in production.
It is also perfect for the road warrior that do not have a connection to its cluster.

Running in a Docker makes it less resource intensive than running on a classic VM.


The image is quite big, might take a while to download the first time.



Ports
---
Hadoop uses a lot of ports
A couple for HDFS, and others for Impala.




Volumes
---

| path | description
|--- |---
| /var/lib/hadoop-hdfs/cache/hdfs/dfs/name | Namenode data directory
| /data/dn | Datanode block directory



##Test it!


This starts impala, and binds the ports to your local machine.

It takes about 60 seconds to start all the services. Be patient.

```
docker run --rm  -ti -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 21000:21000 -p 21050:21050 -p 25000:25000 -p 25010:25010 -p 25020:25020 codingtony/impala 
```

Then you should be able to point your browser to http://localhost:25000 to access the Impala server page.

If you already have impala-shell installed on your machine, you can connect to the impala query interactive shell by doing :

```
impala-shell -i localhost
```

You can try to create a table, insert data, select the data and drop the table :

```
impala-shell -i localhost -q 'create table if not exists test ( test STRING ); insert into test values ("test"); select * from test; drop table test;';
Starting Impala Shell without Kerberos authentication
Connected to localhost:21000
Server version: impalad version 1.4.2-cdh5 RELEASE (build eac952d4ff674663ec3834778c2b981b252aec78)
Query: create table if not exists test ( test STRING )

Returned 0 row(s) in 0.15s
Query: insert into test values ("test")
Inserted 1 rows in 1.20s
Query: select * from test
+------+
| test |
+------+
| test |
+------+
Returned 1 row(s) in 0.17s
Query: drop table test
```

## Run the image as a daemon (with the name impala)
```
docker run -d --name "impala" -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 21000:21000 -p 21050:21050 -p 25000:25000 -p 25010:25010 -p 25020:25020 codingtony/impala
```
