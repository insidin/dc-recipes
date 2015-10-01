A docker-compose recipe to run the Confluent stack, and connect a Divolte-collector to it.

## Start the Divolte collector + Confluent stack
It starts: 
- a (patched) Divolte-collector (dcd/divolte-collector)
- a Confluent Schema-registry (confluent/schema-registry) & Zookeeper (confluent/zookeeper)
- a statsD-enabled Kafka (insidin/kafka) (currently disabled, instead using confluent/kafka atm)

First substitute some environment specific variables in the yml file, by running ```./generate-yml.sh $DATADIR $DNS divolte-confluent-dns.yml``` with a full path $DATADIR and the newly created $DNS IP address. This script generates a customized yml file, divolte-confluent-dns.yml.mine.

The directory $DATADIR/divolte-collector should contain your divolte-collector.conf file. It is made available as /etc/divolte-collector on the container, so use this directory also to store your schema & mapping files. In your divolte-collector.conf file, reference the schema & mapping files with a full path as it is available in the container (so that's /etc/divolte-collector).

Start the containers with ```docker-compose -f divolte-confluent-dns.yml.mine up -d```. You can take a look at the logs via Kitematic.
