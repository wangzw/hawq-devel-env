FROM centos:7

MAINTAINER Zhanwei Wang <wangzw@wangzw.org>

# install document with yum
RUN sed -i 's/tsflags=nodocs//g' /etc/yum.conf

# add yum repo
RUN curl -L "https://bintray.com/wangzw/rpm/rpm" -o /etc/yum.repos.d/bintray-wangzw-rpm.repo

# install all software we need
RUN yum install -y epel-release && \
 yum makecache && \
 yum install -y man passwd sudo tar which git mlocate links make bzip2 \
 autoconf automake libtool m4 gcc gcc-c++ gdb bison flex cmake gperf maven indent \
 libuuid-devel krb5-devel libgsasl-devel expat-devel libxml2-devel \
 perl-ExtUtils-Embed pam-devel python-devel libcurl-devel snappy-devel \
 thrift-devel libyaml-devel libevent-devel bzip2-devel openssl-devel \
 openldap-devel protobuf-devel readline-devel net-snmp-devel apr-devel \
 libesmtp-devel xerces-c-devel python-pip json-c-devel libhdfs3-devel \
 apache-ivy java-1.7.0-openjdk-devel \
 openssh-clients openssh-server && \
 yum clean all

# setup ssh server and keys for root
RUN sshd-keygen && \
 ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa && \
 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
 chmod 0600 ~/.ssh/authorized_keys

# setup JAVA_HOME for all users
RUN echo "#!/bin/sh" > /etc/profile.d/java.sh && \
 echo "export JAVA_HOME=/etc/alternatives/java_sdk" >> /etc/profile.d/java.sh && \
 chmod a+x /etc/profile.d/java.sh

# install libyarn
RUN mkdir -p /tmp/build && \
 cd /tmp/build && git clone --depth=1 https://github.com/apache/incubator-hawq.git . && cd depends/libyarn && mkdir build && cd build && \
 ../bootstrap --prefix=/usr && make && make install && ldconfig && \
 rm -rf /tmp/build

ENV BASEDIR /data
RUN mkdir -p /data && chmod 777 /data

WORKDIR /data

