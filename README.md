# hawq-devel-env

hawq-devel-env is the docker images and scripts to help developers of Apache HAWQ to setup building and testing environment with docker.

We currently support CentOS 6 and CentOS 7, the usage for different platform is the same. We take CentOS 7 as an example in this document.

# Install docker
* following the instructions to install docker.
https://docs.docker.com/

# Setup docker-machine on OSX (optional)
```
# figure out any existing virtual machine, say 'dev'
docker-machine ls

# start the vm called 'dev'
docker-machine start dev

# set up the environment using 'dev'
eval "$(docker-machine env dev)"
```

For details, please check https://docs.docker.com/machine/get-started/

# Setup build and test environment
* clone this repository
```
git clone https://github.com/wangzw/hawq-devel-env.git .
```
* setup a 5 nodes virtual cluster for Apache HAWQ build and test.
```
cd centos7-docker
make run
```
An example output looks like as following
```
[root@centos70-vm1 centos7-docker]# make run
make[1]: Entering directory `/root/hawq-devel-env/centos7-docker'
create centos7-data container
centos7-data container already exist!
make[1]: Leaving directory `/root/hawq-devel-env/centos7-docker'
make[1]: Entering directory `/root/hawq-devel-env/centos7-docker'
make[2]: Entering directory `/root/hawq-devel-env/centos7-docker'
run centos7-namenode container
470dff42a2e09c55bb375e179ca2d751d9477357078c5b47275b249a47f1716d
make[2]: Leaving directory `/root/hawq-devel-env/centos7-docker'
make[2]: Entering directory `/root/hawq-devel-env/centos7-docker'
run centos7-datanode1 container
64a2d097758ff74c0685084b36098373c9720e70ff52ec7f81137af185271517
make[2]: Leaving directory `/root/hawq-devel-env/centos7-docker'
make[2]: Entering directory `/root/hawq-devel-env/centos7-docker'
run centos7-datanode2 container
31ca83f89efd8223d37c7e5c5b0b5b2d52cc0543a60b1625557ccb38b3647733
make[2]: Leaving directory `/root/hawq-devel-env/centos7-docker'
make[2]: Entering directory `/root/hawq-devel-env/centos7-docker'
run centos7-datanode3 container
65a29154c3f5830ac447f599517be42f3d237e3295431c50b0fe023d24bcf311
make[2]: Leaving directory `/root/hawq-devel-env/centos7-docker'
Done!
run "docker exec -it centos7-namenode bash" to attach to centos7-namenode node
make[1]: Leaving directory `/root/hawq-devel-env/centos7-docker'
```
Now let's have a look about what we creted.
```
[root@centos70-vm1 centos7-docker]# docker ps -a
CONTAINER ID        IMAGE                        COMMAND                CREATED             STATUS              PORTS               NAMES
65a29154c3f5        mayjojo/hawq-test:centos7    "entrypoint.sh bash"   2 minutes ago       Up 2 minutes                            centos7-datanode3
31ca83f89efd        mayjojo/hawq-test:centos7    "entrypoint.sh bash"   2 minutes ago       Up 2 minutes                            centos7-datanode2
64a2d097758f        mayjojo/hawq-test:centos7    "entrypoint.sh bash"   2 minutes ago       Up 2 minutes                            centos7-datanode1
470dff42a2e0        mayjojo/hawq-test:centos7    "entrypoint.sh bash"   2 minutes ago       Up 2 minutes                            centos7-namenode
b5986bc9403a        mayjojo/hawq-devel:centos7   "/bin/true"            36 minutes ago      Created                                 centos7-data
```
**centos7-data** is a data container and mounted to /data directory on all other containers to provide a shared storage for the cluster. 

# Build and Test Apache HAWQ
* attach to namenode
```
docker exec -it centos7-namenode bash
```
* check if HDFS working well
```
sudo -u hdfs hdfs dfsadmin -report
```
A sample output should look like as following
```
[gpadmin@centos7-namenode data]$ sudo -u hdfs hdfs dfsadmin -report
Configured Capacity: 321962115072 (299.85 GB)
Present Capacity: 316810412032 (295.05 GB)
DFS Remaining: 316810362880 (295.05 GB)
DFS Used: 49152 (48 KB)
DFS Used%: 0.00%
Under replicated blocks: 0
Blocks with corrupt replicas: 0
Missing blocks: 0
Missing blocks (with replication factor 1): 0

-------------------------------------------------
Live datanodes (3):

Name: 172.18.0.4:50010 (centos7-datanode2)
Hostname: centos7-datanode2
Decommission Status : Normal
Configured Capacity: 107320705024 (99.95 GB)
DFS Used: 16384 (16 KB)
Non DFS Used: 1717174272 (1.60 GB)
DFS Remaining: 105603514368 (98.35 GB)
DFS Used%: 0.00%
DFS Remaining%: 98.40%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 2
Last contact: Mon Jan 18 04:20:26 UTC 2016


Name: 172.18.0.3:50010 (centos7-datanode1)
Hostname: centos7-datanode1
Decommission Status : Normal
Configured Capacity: 107320705024 (99.95 GB)
DFS Used: 16384 (16 KB)
Non DFS Used: 1717346304 (1.60 GB)
DFS Remaining: 105603342336 (98.35 GB)
DFS Used%: 0.00%
DFS Remaining%: 98.40%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 2
Last contact: Mon Jan 18 04:20:24 UTC 2016


Name: 172.18.0.5:50010 (centos7-datanode3)
Hostname: centos7-datanode3
Decommission Status : Normal
Configured Capacity: 107320705024 (99.95 GB)
DFS Used: 16384 (16 KB)
Non DFS Used: 1717182464 (1.60 GB)
DFS Remaining: 105603506176 (98.35 GB)
DFS Used%: 0.00%
DFS Remaining%: 98.40%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 2
Last contact: Mon Jan 18 04:20:25 UTC 2016
```

* clone Apache HAWQ code to /data direcotry
```
git clone https://github.com/apache/incubator-hawq.git /data/hawq
```
* build Apache HAWQ
```
cd /data/hawq
sudo cpan JSON  # Choose the sudo install method and accept the defaults for everything else.
./configure --prefix=/data/hawq-devel
make
make install
```
* modify Apache HAWQ configuration
```
sed 's|localhost|centos7-namenode|g' -i /data/hawq-devel/etc/hawq-site.xml
echo 'centos7-datanode1' >  /data/hawq-devel/etc/slaves
echo 'centos7-datanode2' >>  /data/hawq-devel/etc/slaves
echo 'centos7-datanode3' >>  /data/hawq-devel/etc/slaves
```
* Initialize Apache HAWQ cluster and create default database
```
source /data/hawq-devel/greenplum_path.sh
hawq init cluster
createdb
```
Now you can connect to default database with `psql` command.
```
[gpadmin@centos7-namenode data]$ psql
psql (8.2.15)
Type "help" for help.

gpadmin=#
```
* Running tests
```
cd /data/hawq
make installcheck-good
```
# More command with this script
```
 Usage:
    To setup a build and test environment:         make run
    To start all containers:                       make start
    To stop all containers:                        make stop
    To remove hdfs containers:                     make clean
    To remove all containers:                      make distclean
    To build images locally:                       make build
    To pull latest images:                         make pull
```

