FROM centos:7

MAINTAINER Zhanwei Wang <wangzw@wangzw.org>

# install document with yum
RUN sed -i 's/tsflags=nodocs//g' /etc/yum.conf

# install epel reporistory and upgrade basic image
RUN yum install -y epel-release && \
 yum upgrade -y && \
 yum clean all

# install all software we need
RUN yum install -y man passwd sudo tar which git mlocate links make bzip2 \
 autoconf automake libtool m4 gcc gcc-c++ gdb bison cmake gperf maven indent \
 libuuid-devel krb5-devel libgsasl-devel expat-devel libxml2-devel \
 perl-ExtUtils-Embed pam-devel python-devel libcurl-devel snappy-devel \
 thrift-devel libyaml-devel libevent-devel bzip2-devel openssl-devel \
 openldap-devel protobuf-devel readline-devel net-snmp-devel apr-devel \
 libesmtp-devel xerces-c-devel python-pip \
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

# install json-c 0.9
RUN mkdir -p /tmp/build/ && \
 cd /tmp/build && curl -L https://s3.amazonaws.com/json-c_releases/releases/json-c-0.9.tar.gz -o json-c-0.9.tar.gz && \
 tar -xzf json-c-0.9.tar.gz && cd json-c-0.9 && \
 ./configure --prefix=/usr && make && make install && \
 rm -rf /tmp/build

# install sigar 1.6.4
RUN mkdir -p /tmp/build/ && \
 cd /tmp/build && curl -L https://github.com/hyperic/sigar/archive/sigar-1.6.4.tar.gz -o sigar-1.6.4.tar.gz && \
 tar -xzf sigar-1.6.4.tar.gz && cd sigar-sigar-1.6.4/bindings/perl && \
 perl Makefile.PL ../../ && make DEFINE="-Wall" static && cp blib/arch/auto/Sigar/Sigar.a /usr/lib/libsigar.a && cp -r ../../include/* /usr/include/ && \
 rm -rf /tmp/build

# install flex 2.5.35
RUN mkdir -p /tmp/build/ && \
 cd /tmp/build && curl -L http://downloads.sourceforge.net/project/flex/flex/flex-2.5.35/flex-2.5.35.tar.bz2 -o flex-2.5.35.tar.bz2 && \
 tar -xjf flex-2.5.35.tar.bz2 && cd flex-2.5.35 && \
 ./configure --prefix=/usr && make && make install && \
 rm -rf /tmp/build

# install libhdfs3
RUN mkdir -p /tmp/build && \
 cd /tmp/build && git clone https://github.com/PivotalRD/libhdfs3.git . && mkdir build && cd build && \
 ../bootstrap --prefix=/usr && make && make install && ldconfig && \
 rm -rf /tmp/build

# install libyarn
RUN mkdir -p /tmp/build && \
 cd /tmp/build && git clone --depth=1 https://github.com/apache/incubator-hawq.git . && cd depends/libyarn && mkdir build && cd build && \
 ../bootstrap --prefix=/usr && make && make install && ldconfig && \
 rm -rf /tmp/build

ENV BASEDIR /data
RUN mkdir -p /data

WORKDIR /data
