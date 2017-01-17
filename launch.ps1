echo 'Starting Cluster'
docker rm -f elk_elasticsearch elk_kibana elk_logstash

@"
FROM elasticsearch:5.1.1-alpine

COPY elasticsearch.yml /config/
"@ | Out-file Dockerfile-es  -Encoding utf8

&docker build -f Dockerfile-es -t elasticsearch:5.1.1-alpine .

&docker run --name=elk_elasticsearch -d elasticsearch:5.1.1-alpine -Etransport.host=127.0.0.1
&docker run --name=elk_kibana --link elk_elasticsearch:elasticsearch -p 5601:5601 -d kibana:5.1.1

@"
FROM logstash:5.1.1-alpine

COPY logstash.conf /config/

CMD ["-f", "/config/logstash.conf"]
EOF
"@ | out-file dockerfile -Encoding utf8

&docker build -t logstash-with-config:5.1.1 .

&docker run -d `
  -p 5000:5000 `
  -p 5000:5000/udp `
  --link elk_elasticsearch:elasticsearch `
  --name elk_logstash `
  -e LOGSPOUT=ignore `
  logstash-with-config:5.1.1

sleep 1
echo 'Cluster started'
echo 'Creating Log Messages'
$LOGSTASH_ADDRESS=(docker inspect --format '{{ .NetworkSettings.IPAddress }}' elk_logstash)
docker run -d --log-driver=gelf `
  --log-opt gelf-address=udp://$LOGSTASH_ADDRESS:12201 `
  ubuntu `
  bash -c 'for i in {0..60}; do echo Message $i; sleep 1; done'
