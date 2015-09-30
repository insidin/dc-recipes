A docker-compose recipe to run a hadoop cluster.

## Start the hadoop cluster

First substitute some environment specific variables in the yml file, by running ```./generate-yml.sh $DATADIR $DNS hadoop-dns.yml``` with a full path $DATADIR and the newly created $DNS IP address. This script generates a customized yml file, hadoop-dns.yml.mine.

Now using this file, first format the namenode: ```docker-compose -f hadoop-dns.yml.mine run namenode hdfs namenode -format```. Warning: if your hadoop cluster already contained data, this command ask you to confirm if you want to reformat (and thus erase) the data folders.

Finally start the containers with ```docker-compose -f hadoop-dns.yml.mine up -d```. You can take a look at the logs via Kitematic or via the logs files located at ```$DATADIR\<hostname>\logs```.

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
