Dockerfile for Cloudera Impala 1.4
==

This Dockerfile runs a [Cloudera Impala 1.4](http://impala.io/) server on a single node Hadoop Cluster.

This image is based on [codingtony/cdh5-base](https://github.com/codingtony/docker/tree/master/cdh5-base). Which is essentially CDH5 on Ubuntu 12.04 precise.

##Features

It runs a single node cluster with a datanode and a namenode running on the same machine.
It also runs Impala server, Impala state store and Impala catalog


Don't expect great performance. But it provides enough functionality to test Impala queries without disturbing the cluster.

It's great for developpers that want to test their queries before running in production.
It is also perfect for the road warrior that do not have a connection to its cluster.

Running in a Docker makes it less resource intensive than running on a classic VM.


The image is quite big (1.5GB). It might take a while to download the first time.


Ports
---
Hadoop uses a lot of ports
A couple for HDFS, and others for Impala.

| Ports | Service |
| --- | ---
| 9000 | Name Node IPC |
| 50010 | Data Node Data transfer |
| 50020 | Data Node IPC |
| 50070 | Name Node HTTP |
| 50075 | Data Node HTTP |
| 21000 | Impala shell |
| 21050 | Impala JDBC / ODBC |
| 25000 | Impala Server HTTP |
| 25010 | Impala State HTTP |
| 25020 | Impala Catalog HTTP |

Volumes
---

| path | description
|--- |---
| /var/lib/hadoop-hdfs/cache/hdfs/dfs/name | Namenode data directory
| /data/dn | Datanode block directory



##Test it!


This starts Impala, and binds the ports to your local machine.

It takes about 60 seconds to start all the services. Be patient.
At the end this will drop you in a shell and you will be able to play with the image.
This will map the ports of your machine to the port in the container

```
docker run --rm  -ti  -p 9000:9000 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 21000:21000 -p 21050:21050 -p 25000:25000 -p 25010:25010 -p 25020:25020 codingtony/impala /start-bash.sh
```

Then you should be able to point your browser to [http://localhost:25000](http://localhost:25000) to access the Impala server page.



## Create a named container called "impala" 
It will run as a daemon, exposing the ports
```
docker run -d --name "impala" -p 9000:9000 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -p 21000:21000 -p 21050:21050 -p 25000:25000 -p 25010:25010 -p 25020:25020 codingtony/impala
```

### Use docker to query your Impala server


Of course, if you already have impala-shell installed on your machine, you can simply connect to Impala using the interactive shell by doing :

```
impala-shell -i localhost
```

But why not using a docker container to do the queries? That way, you won't have to install all the Hadoop software on your host!
```
docker run --rm -ti --link impala:impala-server codingtony/impala impala-shell -i impala-server
```
See [Linking Containers Together](https://docs.docker.com/userguide/dockerlinks/) in Docker's documentation if you want more detail on how to connect containers together.


You can now try to create a table, insert data, select the data and drop the table :

```
docker run --rm  --link impala:impala-server codingtony/impala impala-shell -i impala-server -q 'create table if not exists test ( test STRING ); insert into test values ("test"); select * from test; drop table test;';
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

**It works !**


## Putting file in HDFS

Now the fun begins, you will be able to add some files to HDFS!

The HDFS directory /tmp has been created for you during the build.
You can put files from your host to the "impala" container using docker.

It involves using an intermiate script that will modify core-site.xml prior running the real hadoop command.
The script will put the right hostname in the core-site.xml so that the hadoop command will know where to connect to HDFS.

The small script is called hdp, and takes at least 2 parameters.
The first is the name of the link you've used to connect to your running container.

You invoke the script before using the standard hadoop commands.

See the example below :
```
docker run --rm  --link impala:impala-server codingtony/impala hdp impala-server hadoop fs -ls /
Found 2 items
drwxrwxrwx   - hdfs supergroup          0 2014-10-05 02:12 /tmp
drwxr-xr-x   - hdfs supergroup          0 2014-10-05 02:12 /user
```

Pretty cool!


Now here's how to put file from your host into the HDFS that runs in the "impala" container

There is at least two ways to do it.

### Using the container stdin

You push the data into docker's stdin, and you indicate to ``hadoop fs -put`` to read from stdin using "-" and you specify the destination file.

Here's how it works :
```
echo test  | docker run --rm  --link impala:impala-server codingtony/impala hdp impala-server hadoop fs -put - /tmp/IMPALA.TXT

docker run --rm  --link impala:impala-server codingtony/impala hdp impala-server hadoop fs -ls /tmp
Found 1 items
-rw-r--r--   1 root supergroup          0 2014-10-05 02:30 /tmp/IMPALA.TXT
```

### Using a local volume

You mount a filesystem from the host and you make it available in the container using -v. 

Here's how it works :
```
#create the file on the host :
touch /tmp/IMPALA.txt
docker run --rm  --link impala:impala-server -v /tmp/:/work:ro codingtony/impala hdp impala-server hadoop fs -put /work/IMPALA.txt /tmp/IMPALA_USING_VOLUME.txt
```




