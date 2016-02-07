echo 'Starting Cluster'
echo 'Assumes Docker host is called docker'

docker rm -f  elk_es kibana logspout logstash logstash_config

docker run -d \
  -p 9200:9200 \
  -p 9300:9300 \
  --name elk_es \
  -e LOGSPOUT=ignore \
  elasticsearch:1.5.2
  
docker create -v /config --name logstash_config busybox
docker cp logstash.conf logstash_config:/config/

docker run -d \
  -p 5000:5000 \
  -p 5000:5000/udp \
   --volumes-from logstash_config
  --link elk_es:elasticsearch \
  --name logstash \
  -e LOGSPOUT=ignore \
  logstash:2.1.1  -f /config/logstash.conf

docker run -d \
  -p 5601:5601 \
  --link elk_es:elasticsearch \
  --name kibana \
  -e LOGSPOUT=ignore \
  kibana:4.1.2

ip=$(ping -c 1 docker | awk -F'[()]' '/PING/{print $2}')
docker run -d \
  -v /var/run/docker.sock:/tmp/docker.sock \
  --name logspout \
  -e LOGSPOUT=ignore \
  -e DEBUG=true \
  --publish=$ip:8000:80 \
  gliderlabs/logspout:master syslog://$ip:5000

sleep 1
echo 'Cluster started'
echo 'Creating Log Messages'
docker run -d ubuntu bash -c 'for i in {0..60}; do echo $i; sleep 1; done'

