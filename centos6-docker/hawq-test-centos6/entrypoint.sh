#!/bin/bash

/etc/init.d/sshd start

if [ -z "${NAMENODE}" ]; then
  export NAMENODE=${HOSTNAME}
fi

if [ ! -f /etc/profile.d/hadoop.sh ]; then
  echo "#!/bin/bash" > /etc/profile.d/hadoop.sh
  echo "export NAMENODE=${NAMENODE}" >> /etc/profile.d/hadoop.sh
  chmod a+x /etc/profile.d/hadoop.sh
fi

if [ "${NAMENODE}" == "${HOSTNAME}" ]; then
  if [ ! -d /tmp/hdfs/name/current ]; then
    su -l hdfs -c "hdfs namenode -format"
  fi
  
  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.namenode.NameNode | grep -v grep`" ]; then
    su -l hdfs -c "hadoop-daemon.sh start namenode"
  fi
else
  if [ -z "`ps aux | grep org.apache.hadoop.hdfs.server.datanode.DataNode | grep -v grep`" ]; then
    su -l hdfs -c "hadoop-daemon.sh start datanode"
  fi
fi

exec "$@"
