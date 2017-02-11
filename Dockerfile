FROM logstash:5.2.0-alpine

COPY logstash.conf /config/

CMD ["-f", "/config/logstash.conf"]
