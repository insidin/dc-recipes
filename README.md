# dc-recipes

## Divolte-confluent

Starts: 

- a (patched) Divolte-collector (dcd/divolte-collector)
- a Confluent Schema-registry (confluent/schema-registry) & Zookeeper (confluent/zookeeper)
- a statsD-enabled Kafka (dcd/kafka)

Docker images need to be pulled (for the conluent images) or build (for the dcd images, see https://github.com/insidin/docker-recipes)

Confguration:

- modify divolte-confluent.yml and replace "HOST_IP" with the docker host IP address.

# Running docker-compose

Execute docker-compose to start the containers
>docker-compose up -d

To shutdown, execute
>docker-compose stop


# Retrieving the host IP address

To retrieve the host IP address, run 

> boot2docker ip

or
> docker-machine ip dev

where "dev" is the machine name selected from running
> docker-machine ls



