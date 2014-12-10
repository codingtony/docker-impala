#ubuntu trusty build
#this is a fork off codingtony and updated to impala 2.0.1
#see: https://github.com/codingtony/docker-impala
#see: http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html
#see: http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/impala_noncm_installation.html
#To test: docker run --rm -ti rooneyp1976/impala /start-bash.sh

FROM ubuntu:14.04
MAINTAINER rooneyp1976@yahoo.com

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install wget -y
RUN wget http://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb
RUN dpkg -i /cdh5-repository_1.0_all.deb
RUN sudo apt-get update -y


#install oracle java 7
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update -y
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer vim

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install hadoop-hdfs-namenode hadoop-hdfs-datanode -y
RUN apt-get install impala impala-server impala-shell impala-catalog impala-state-store -y

RUN mkdir /var/run/hdfs-sockets/ ||:
RUN chown hdfs.hadoop /var/run/hdfs-sockets/

RUN mkdir -p /data/dn/
RUN chown hdfs.hadoop /data/dn

# Hadoop Configuration files
# /etc/hadoop/conf/ --> /etc/alternatives/hadoop-conf/ --> /etc/hadoop/conf/ --> /etc/hadoop/conf.empty/
# /etc/impala/conf/ --> /etc/impala/conf.dist
ADD files/core-site.xml /etc/hadoop/conf/
ADD files/hdfs-site.xml /etc/hadoop/conf/
ADD files/core-site.xml /etc/impala/conf/
ADD files/hdfs-site.xml /etc/impala/conf/

# Various helper scripts
ADD files/start.sh /
ADD files/start-hdfs.sh /
ADD files/start-impala.sh /
ADD files/start-bash.sh /
ADD files/start-daemon.sh /
ADD files/hdp /usr/bin/hdp

# HDFS PORTS :
# 9000  Name Node IPC
# 50010 Data Node Transfer
# 50020 Data Node IPC
# 50070 Name Node HTTP
# 50075 Data Node HTTP 


# IMPALA PORTS :
# 21000 Impala Shell
# 21050 Impala ODBC/JDBC
# 25000 Impala Daemon HTTP
# 25010 Impala State Store HTTP
# 25020 Impala Catalog HTTP

EXPOSE 9000 50010 50020 50070 50075 21000 21050 25000 25010 25020

CMD /start-daemon.sh

