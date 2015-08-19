# dc-recipes

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

# Running docker-compose

Execute docker-compose to start the containers
>docker-compose -f $DC-RECIPY.yml up -d

To shutdown, execute
>docker-compose stop

# Retrieving the host IP address

To retrieve the host IP address, run 

> boot2docker ip

or
> docker-machine ip dev

where "dev" is the machine name selected from running
> docker-machine ls



