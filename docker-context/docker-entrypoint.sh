#!/bin/bash

sudo service ssh start

HADOOP_TMP_DIR=$(${HADOOP_HOME}/bin/hdfs getconf -confKey hadoop.tmp.dir)
sudo chown hdfs:hdfs $(dirname ${HADOOP_TMP_DIR})

if [ ! -d "/var/hadoop/hdfs/dfs/name" ]; then
    ${HADOOP_HOME}/bin/hdfs namenode -format
fi

${HADOOP_HOME}/sbin/start-dfs.sh
${HADOOP_HOME}/sbin/start-yarn.sh

while /bin/true; do
    sleep 1000
done
