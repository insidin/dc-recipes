# Docker-compose recipes

## Docker machine

Check if a default machine exists: 
>docker-machine ls


Delete the default machine: 
>docker-machine rm default

Create a new "default" machine:
>docker-machine create -d virtualbox --engine-opt dns=8.8.8.8 --engine-opt bip=172.17.42.1/24 --engine-opt dns=172.17.42.1 --engine-opt host=unix:///var/run/docker.sock --virtualbox-memory "2048" default

## Network setting

Set your (updated) environment in the terminal first
>eval "$(docker-machine env default)"

Check the machine IP (we refer to this as MACHINE_IP later on)
>docker-machine ip default

Update your host network routing to easily connect to machine IP's:
>sudo route -n add 172.17.0.0/16  \`docker-machine ip default\`

(if this routing existed already, remove it first using 
>sudo route -n delete 172.17.0.0/16 ...

## Support

Starts:
- a DNS server
- a data container

Install support.yml:
> docker-compose -f support.yml up -d

## Network part 2

Configure your host system to use the DNS server:

First get the IP of the DNS server
> docker-machine ssh default
> 
> ifconfig docker0 

Add this to the dns server list of your host.

## Start the hadoop cluster

> ./generate-yml.sh data-dir dns-ip hadoop-dns.yml

This generates a customized yml file, hadoop-dns.yml.mine.

Format the namenode:

> docker-compose -f hadoop-dns.yml.mine run namenode hdfs namenode -format

Start the containers:

> docker-compose -f hadoop-dns.yml.mine up -d

## Host hadoop client config

In your HADOOP_HOME/etc/hadoop folder:

- Edit core-site.xml and add
><property>
>   <name>fs.defaultFS</name>
>	<value>hdfs://namenode.docker:8020</value>
></property>

- Edit yarn-site.xml and add
><property>
>	<name>yarn.resourcemanager.hostname</name>
>   <value>resourcemgr.docker</value>
></property>

## Test HDFS access

In your HADOOP_HOME folder, run 

> ./bin/hdfs dfs -mkdir /test 

> ./bin/hdfs dfs -ls /

## Test a Spark job:

First, set the Hadoop configuration path: hadoop conf dir

> export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

Than, in your Spark installation, run:

> ./bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn-client --num-executors 3 --executor-cores 1 lib/spark-examples*.jar 100






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



