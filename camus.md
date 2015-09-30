# Camus

To run Camus, first start both the Divolte-confluent and Hadoop containers. Then, start a container to run Camus, by executing:

docker run -it --hostname camus1 --dns $DNS -v $DATADIR/camus:/shared insidin/alpine-confluent /bin/bash

You should replace the $DATADIR and $DNS and make sure the folder $DATADIR/camus exists on your local filesystem, containing your camus.properties file.

Now in the started camus1 container, run camus by executing:
> cd /opt/confluent
> bin/camus-run -D schema.registry.url=http://schemaregistry1.docker:8081 -D kafka.move.to.earliest.offset=true -D is.new.producer=false -P /shared/camus.properties


