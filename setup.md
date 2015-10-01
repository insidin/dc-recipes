Setting up the docker environment.

## Preparation

###Docker machine
First check if a default machine exists by executing ```docker-machine ls```. Kitematic creates and uses a machine named ```default```, but we need to reconfigure it first. Warning: this will delete all current (Kitematic) containers.

Delete the default machine by executing ```docker-machine rm default```. Afterwards, rereate the new ```default machine```:

>docker-machine create -d virtualbox --engine-opt dns=8.8.8.8 --engine-opt dns=172.17.42.1 --engine-opt bip=172.17.42.1/24 --engine-opt host=unix:///var/run/docker.sock --virtualbox-memory "2048" default

###Virtual machine diskspace
The hadoop setup maps 2 directories, one to the host machine and one to the virtual machine (via a data container).

If you notice a failing health check on the Hadoop datanodes, check the available disk size of partition /dev/sda1 (mounted to /data). Login on the vm via ```docker-machine ssh default``` and execute ```df```. If the usage of ```/dev/sda``` approaches the 100%, you can free some space by removing docker images. To do so, on your host machine first execute ```eval "$(docker-machine env default)"``` in a terminal to be able to connect to docker. Than execute (at your own risk!) ```docker rmi $(docker images -q -f dangling=true)``` to remove docker images and free some space.

### Run supporting containers
To support the installation, a DNS server and a data-only container are started by running ```docker-compose -f support.yml up -d```.

### Configure host network settings
Set your (updated) environment in the terminal first by executing ```eval "$(docker-machine env default)"```. Check and note the machine IP by running ```docker-machine ip default```.

Update your host network routing to easily connect to machine IP's. On the host machine execute ```sudo route -n add 172.17.0.0/16  `docker-machine ip default` ```. If this routing existed already, remove it first by using ```sudo route -n delete 172.17.0.0/16 ...```.

Now configure your host system to use the newly created DNS server. First get the IP of the DNS server. Login on the virtual machine via ```docker-machine ssh default```and execute ```ifconfig docker0```. The IP address of the docker0 interface is your DNS server IP address, we'll refer to it as $DNS_IP. Simply type ```exit```to return to the host machine.

Add $DNS_IP to the DNS server list of your host machine as the first DNS server. Additionally, create a file ```/etc/resolver/docker``` (you might need to create the folder, and may need to become ```su``` for this) with a single line content: 
> nameserver $DNS_IP

Tip: on Mac OSX, create a new network location via ```network preferences``` so you can easily revert back to the default DNS settings when your dockerized DNS server is not running. 