# Docker-compose recipes

## Preparation

###Docker machine

Check if a default machine exists: 
>docker-machine ls

Delete the default machine: 
>docker-machine rm default

Create a new "default" machine:
>docker-machine create -d virtualbox --engine-opt dns=8.8.8.8 --engine-opt bip=172.17.42.1/24 --engine-opt dns=172.17.42.1 --engine-opt host=unix:///var/run/docker.sock --virtualbox-memory "2048" default

### Run supporting containers

Starts:
- a DNS server
- a data container

Install support.yml:
> docker-compose -f support.yml up -d

### Configure host network settings

Set your (updated) environment in the terminal first by executing ```eval "$(docker-machine env default)"```. Check and note the machine IP by running ```docker-machine ip default```.

Now Update your host network routing to easily connect to machine IP's. On the host machine execute ```sudo route -n add 172.17.0.0/16  ``docker-machine ip default`` ```. If this routing existed already, remove it first by using ```sudo route -n delete 172.17.0.0/16 ...```.

Now configure your host system to use the newly created DNS server. First get the IP of the DNS server. Login on the virtual machine via ```docker-machine ssh default```and execute ```ifconfig docker0```. Add this IP address to the DNS server list of your host machine as the first DNS server. Simply type `````exit```to return to the host machine.

Tip: on Mac OSX, create a new network location so you can easily revert back to the default DNS settings when your dockerized DNS server is not running. 

## Start the hadoop cluster

First substitute some environment specific variables in the yml file, by running ```./generate-yml.sh <data-dir> <dns-ip> hadoop-dns.yml``` with a full path data-dir and the newly created DNS server IP address. This script generates a customized yml file, hadoop-dns.yml.mine.

Now using this file, first format the namenode: ```docker-compose -f hadoop-dns.yml.mine run namenode hdfs namenode -format```. Warning: if your hadoop cluster already contained data, this command ask you to confirm if you want to reformat (and thus erase) the data folders.

Finally start the containers with ```docker-compose -f hadoop-dns.yml.mine up -d```. You can take a look at the logs via Kitematic or via the logs files located at ```<data-dir>\<hostname>\logs```.

## Test the hadoop cluster

###Host hadoop client config

On the host machine, in your HADOOP_HOME/etc/hadoop folder:

- Edit core-site.xml and add
```xml
<property>
   <name>fs.defaultFS</name>
	<value>hdfs://namenode.docker:8020</value>
</property>
```
- Edit yarn-site.xml and add
```xml
<property>
	<name>yarn.resourcemanager.hostname</name>
   <value>resourcemgr.docker</value>
</property>
```

### Test host HDFS access

On the host machine, in your HADOOP_HOME folder, create a test directory on hdfs: 

> ./bin/hdfs dfs -mkdir /test 

Verify the existence of the directory:

> ./bin/hdfs dfs -ls /

### Test a Spark job:

First, configure the path to Hadoop conf dir on the host:

> export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

In your Spark installation folder, run:

> ./bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn-client --num-executors 2 --executor-cores 2 lib/spark-examples*.jar 100

## Configuration customization

To set specific hadoop configuration, first externalize the config files. To do so, copy the conf folder from https://github.com/insidin/docker-recipes/tree/master/alpine-hadoop/conf to the host file system.

Link the newly created config to your hadoop nodes:

- open hadoop-dns.yml.mine
- add a volume mapping to each container: e.g. add the following under "volumes":
```
volumes:
	- <path-to-you-conf-folder>:/shared/conf
```
- set the mapped volume as an environment variable, by adding the following under "environment":
```
environment:
	- HADOOP_CONF_DIR=/shared/conf
```


Deprecated:



## Divolte-confluent

Starts: 
- a (patched) Divolte-collector (dcd/divolte-collector)
- a Confluent Schema-registry (confluent/schema-registry) & Zookeeper (confluent/zookeeper)
- a statsD-enabled Kafka (dcd/kafka)

Docker images need to be pulled (for the conluent images) or build (for the dcd images, see https://github.com/insidin/docker-recipes)

Configuration: modify divolte-confluent.yml and 
- replace $HOST_IP with the docker host IP address
- replace $DIVOLTE-COLLECTOR-CONF-DIR with the folder where you put you divolte-collector.conf file

The directory $DIVOLTE-COLLECTOR-CONF-DIR is made available as /etc/divolte-collector on the container, so use this path to reference files located there (e.g. your schema & mapping files).

## Hadoop

Starts: 
- a namenode (dcd/alpine-hadoop)
- 3 datanodes (dcd/alpine-hadoop)

Docker images need to be pulled (for the conluent images) or build (for the dcd images, see https://github.com/insidin/docker-recipes)

Configuration: modify hadoop.yml and 
- replace $DATADIR with a folder on the local fs (and make sure the subdirectories datanode1, datanode2, datanode3 and namenode exist)

Before starting, initialize the hdfs filesystem by executing
> docker-compose -f hadoop.yml run namenode hdfs namenode -format 

(You might need to delete old datanode directory subfolders if present)

# Camus

To run Camus, first start both the Divolte-confluent and hadoop containers. Then, start a container to run Camus, by executing:
> docker run -it --hostname camus1 --link dcdhadoop_namenode_1:namenode --link dcdconfluent_kafka_1:kafka --link dcdconfluent_zookeeper_1:zookeeper --link dcdconfluent_schemaregistry_1:schemaregistry -v $DATADIR/camus:/shared dcd/alpine-confluent /bin/bash

You should replace the $DATADIR and make sure the folder $DATADIR/camus exists on your local filesystem, containing your camus.properties file.

Now in the started camus1 container, run camus by executing:
> cd /opt/confluent
> bin/camus-run -D schema.registry.url=http://schemaregistry:8081 -D is.new.producer=false -P /shared/camus.properties

# Linking the local filesystem

- make sure the $DATADIR folders are subdirectories of the virtualbox shared folders of the vm
- todo: to be able to write in the folders


# Running docker-compose

Execute docker-compose to start the recipe containers, e.g. for the hadoop recipy, run 
>docker-compose -f hadoop.yml up -d

To shutdown, execute
>docker-compose stop

# Retrieving the host IP address

To retrieve the host IP address, run 

> boot2docker ip

or
> docker-machine ip dev

where "dev" is the machine name selected from running
> docker-machine ls



