#!/bin/bash

/usr/sbin/sshd

if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
  if [ ! -d /tmp/hdfs/name/current ]; then
    su -l hdfs -c "hdfs namenode -format"
  fi
  
  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.namenode.NameNode | grep -v grep`" ]; then
    su -l hdfs -c "hadoop-daemon.sh start namenode"
    sudo -u hdfs hdfs dfs -chmod 777 /
  fi
else
  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.datanode.DataNode | grep -v grep`" ]; then
    su -l hdfs -c "hadoop-daemon.sh start datanode"
  fi
fi

