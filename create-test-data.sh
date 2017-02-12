echo 'Creating Log Messages'
LOGSTASH_ADDRESS=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerelk_logstash_1)

if [ "$LOGSTASH_ADDRESS" = "" ]; then
  echo "Logstash instance not found. Is it running? Is the name correct?"
  exit 1
fi

docker run -td --log-driver=gelf \
  --log-opt gelf-address=udp://$LOGSTASH_ADDRESS:12201 \
  ubuntu \
  bash -c 'for i in {0..60}; do echo Message $i; sleep 1; done'
