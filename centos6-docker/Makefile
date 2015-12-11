#!/usr/bin/make all

THIS_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
TOP_DIR := $(abspath $(dir ${THIS_MAKEFILE_PATH}))
NDATANODES := 3
CUR_DATANODE := 1
OS_VERSION := centos6
# Do not use underscore "_" in CLUSTER_ID
CLUSTER_ID := $(OS_VERSION)
# Monut this local directory to /data in data container and share with other containers
LOCAL :=
# networks used in docker
NETWORK := $(CLUSTER_ID)_hawq_network

all: 
	@echo " Usage:"
	@echo "    To setup a build and test environment:         make run"
	@echo "    To start all containers:                       make start"
	@echo "    To stop all containers:                        make stop"
	@echo "    To remove hdfs and devel containers:           make remove"
	@echo "    To remove all containers:                      make clean"
	@echo ""
	@echo "    To setup a hdfs cluster:                       make run-hdfs"
	@echo "    To start hdfs containers:                      make start-hdfs"
	@echo "    To stop hdfs containers:                       make stop-hdfs"
	@echo "    To remove hdfs containers:                     make remove-hdfs"
	@echo ""
	@echo "    To setup a devel container:                    make run-devel"
	@echo "    To start a devel container:                    make start-devel"
	@echo "    To stop a devel container:                     make stop-devel"
	@echo "    To remove devel container:                     make remove-devel"
	@echo ""
	@echo "    To remove data container:                      make remove-data"
	@echo "    To build images locally:                       make build"
	@echo "    To pull latest images:                         make pull"

build:
	@make -f $(THIS_MAKEFILE_PATH) build-hawq-devel-$(OS_VERSION)
	@make -f $(THIS_MAKEFILE_PATH) build-hawq-test-$(OS_VERSION)
	@echo "Done!"

build-hawq-devel-$(OS_VERSION): $(TOP_DIR)/hawq-devel-$(OS_VERSION)/Dockerfile
	@echo build hawq-devel:$(OS_VERSION) image
	docker build -t mayjojo/hawq-devel:$(OS_VERSION) $(TOP_DIR)/hawq-devel-$(OS_VERSION)/

build-hawq-test-$(OS_VERSION): $(TOP_DIR)/hawq-test-$(OS_VERSION)/Dockerfile
	@echo build hawq-test:$(OS_VERSION) image
	docker build -t mayjojo/hawq-test:$(OS_VERSION) $(TOP_DIR)/hawq-test-$(OS_VERSION)/

create-data-container:
	@echo create ${CLUSTER_ID}-data container
	@if [ ! -z "$(LOCAL)" -a ! -d "$(LOCAL)" ]; then \
		echo "LOCAL must be set to a directory!"; \
		exit 1; \
	fi
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-data" | grep -v CONTAINER`" ]; then \
		if [ -z "$(LOCAL)" ]; then \
			docker create -v /data --name=${CLUSTER_ID}-data mayjojo/hawq-devel:$(OS_VERSION) /bin/true; \
		else \
			docker create -v $(LOCAL):/data --name=${CLUSTER_ID}-data mayjojo/hawq-devel:$(OS_VERSION) /bin/true; \
		fi \
	else \
		echo "${CLUSTER_ID}-data container already exist!"; \
	fi

create-devel:
	@make -f $(THIS_MAKEFILE_PATH) create-data-container 2>&1 >/dev/null
	@echo create ${CLUSTER_ID}-devel container
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-devel" | grep -v CONTAINER`" ]; then \
		docker run -itd --net=$(NETWORK) --hostname=${CLUSTER_ID}-devel --name=${CLUSTER_ID}-devel \
		        --volumes-from ${CLUSTER_ID}-data mayjojo/hawq-devel:$(OS_VERSION); \
	else \
		echo "${CLUSTER_ID}-devel container already exist!"; \
	fi

run:
	@if [ -z "`docker network ls 2>/dev/null`" ]; then \
                make -f $(THIS_MAKEFILE_PATH) NETWORK=default create-data-container && \
                make -f $(THIS_MAKEFILE_PATH) NETWORK=default create-devel && \
                make -f $(THIS_MAKEFILE_PATH) NETWORK=default run-hdfs; \
	else \
	        if [ -z "`docker network ls 2>/dev/null | grep $(NETWORK)`" ]; then \
	                echo create network $(NETWORK) && \
	                docker network create --driver bridge $(NETWORK); \
	        fi && \
	        make -f $(THIS_MAKEFILE_PATH) create-data-container && \
                make -f $(THIS_MAKEFILE_PATH) create-devel && \
                make -f $(THIS_MAKEFILE_PATH) run-hdfs; \
	fi

run-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) run-namenode-container
	@for (( i=1; i<=$(NDATANODES); ++i )); do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i run-datanode-container; \
	done
	@echo "Done!"
	@echo 'run "docker exec -it ${CLUSTER_ID}-devel bash" to attach to ${CLUSTER_ID}-devel node'

run-namenode-container:
	@echo "run ${CLUSTER_ID}-namenode container"
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker run -itd --net=$(NETWORK) --hostname=${CLUSTER_ID}-namenode --name=${CLUSTER_ID}-namenode \
			--volumes-from ${CLUSTER_ID}-data mayjojo/hawq-test:$(OS_VERSION); \
	else \
		echo "${CLUSTER_ID}-namenode container already exist!"; \
	fi

run-datanode-container:
	@echo "run ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker run -itd --net=$(NETWORK) --hostname=${CLUSTER_ID}-datanode$(CUR_DATANODE) \
			--name=${CLUSTER_ID}-datanode$(CUR_DATANODE) -e NAMENODE=${CLUSTER_ID}-namenode \
		  --volumes-from ${CLUSTER_ID}-data mayjojo/hawq-test:$(OS_VERSION); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container already exist!"; \
	fi

start:
	@make -f $(THIS_MAKEFILE_PATH) start-devel
	@make -f $(THIS_MAKEFILE_PATH) start-hdfs
	@echo 'run "docker exec -it ${CLUSTER_ID}-devel bash" to attach to ${CLUSTER_ID}-devel node'

start-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) start-namenode-container
	@for (( i=1; i<=$(NDATANODES); ++i )); do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i start-datanode-container; \
	done
	@echo "Done!"

start-namenode-container:
	@echo "start ${CLUSTER_ID}-namenode container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker start ${CLUSTER_ID}-namenode; \
	else \
		echo "${CLUSTER_ID}-namenode container does not exist!" && exit 1; \
	fi

start-datanode-container:
	@echo "start ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker start ${CLUSTER_ID}-datanode$(CUR_DATANODE); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container does not exist!" && exit 1; \
	fi

start-devel:
	@echo "start ${CLUSTER_ID}-devel container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-devel" | grep -v CONTAINER`" ]; then \
		docker start ${CLUSTER_ID}-devel; \
	else \
		echo "${CLUSTER_ID}-devel container does not exist!" && exit 1; \
	fi

stop:
	@make -f $(THIS_MAKEFILE_PATH) stop-devel
	@make -f $(THIS_MAKEFILE_PATH) stop-hdfs

stop-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) stop-namenode-container
	@for (( i=1; i<=$(NDATANODES); ++i )); do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i stop-datanode-container; \
	done
	@echo "Done!"

stop-namenode-container:
	@echo "stop ${CLUSTER_ID}-namenode container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker stop -t 0 ${CLUSTER_ID}-namenode; \
	else \
		echo "${CLUSTER_ID}-namenode container does not exist!"; \
	fi

stop-datanode-container:
	@echo "stop ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker stop -t 0 ${CLUSTER_ID}-datanode$(CUR_DATANODE); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container does not exist!"; \
	fi

stop-devel:
	@echo "stop ${CLUSTER_ID}-devel container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-devel" | grep -v CONTAINER`" ]; then \
		docker stop -t 0 ${CLUSTER_ID}-devel; \
	else \
		echo "${CLUSTER_ID}-devel container does not exist!"; \
	fi

remove:
	@make -f $(THIS_MAKEFILE_PATH) remove-devel
	@make -f $(THIS_MAKEFILE_PATH) remove-hdfs

remove-hdfs:
	@make -f $(THIS_MAKEFILE_PATH) remove-namenode-container
	@for (( i=1; i<=$(NDATANODES); ++i )); do \
		make -f $(THIS_MAKEFILE_PATH) CUR_DATANODE=$$i remove-datanode-container; \
	done
	@echo "Done!"

remove-namenode-container:
	@echo "make ${CLUSTER_ID}-namenode container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-namenode" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-namenode; \
	else \
		echo "${CLUSTER_ID}-namenode container does not exist!"; \
	fi

remove-datanode-container:
	@echo "make ${CLUSTER_ID}-datanode$(CUR_DATANODE) container"
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-datanode$(CUR_DATANODE)" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-datanode$(CUR_DATANODE); \
	else \
		echo "${CLUSTER_ID}-datanode$(CUR_DATANODE) container does not exist!"; \
	fi

remove-data:
	@echo remove ${CLUSTER_ID}-data container
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-data" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-data; \
	else \
		echo "${CLUSTER_ID}-data container does not exist!"; \
	fi

remove-devel:
	@echo remove ${CLUSTER_ID}-devel container
	@if [ ! -z "`docker ps -a --filter="name=${CLUSTER_ID}-devel" | grep -v CONTAINER`" ]; then \
		docker rm ${CLUSTER_ID}-devel; \
	else \
		echo "${CLUSTER_ID}-devel container does not exist!"; \
	fi

pull:
	@echo latest images
	docker pull mayjojo/hawq-devel:$(OS_VERSION)
	docker pull mayjojo/hawq-test:$(OS_VERSION)

clean:
	@make -f $(THIS_MAKEFILE_PATH) stop 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove 2>&1 >/dev/null || true
	@make -f $(THIS_MAKEFILE_PATH) remove-data 2>&1 >/dev/null || true
	@if [ ! -z "`docker network ls 2>/dev/null | grep $(NETWORK)`" ]; then \
	        echo remove network $(NETWORK); \
	        docker network rm $(NETWORK) 2>&1 >/dev/null || true; \
	fi
	@echo "Done!"
