echo 'Creating Log Messages'
docker rm -f logspout
LOGSTASH_ADDRESS=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerelk_logstash_1)

if [ "$LOGSTASH_ADDRESS" = "" ]; then
  echo "Logstash instance not found. Is it running? Is the name correct?"
  exit 1
fi

docker run -d \
  -v /var/run/docker.sock:/tmp/docker.sock \
  --name logspout \
  -e LOGSPOUT=ignore \
  -e DEBUG=true \
  -p 8000:80 \
  gliderlabs/logspout:master syslog://$LOGSTASH_ADDRESS:5000
sleep 1

docker run -d ubuntu bash -c 'for i in {0..60}; do echo Message via Logspout $i; sleep 1; done'

echo 'View debug logstream on port 8000'

# Only log certain containers
# docker run --volume=/var/run/docker.sock:/var/run/docker.sock gliderlabs/logspout syslog://$LOGSTASH_ADDRESS:5000?filter.name=*_logme%2Candme*
