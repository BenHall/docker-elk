FROM logstash:5.1.1-alpine

COPY logstash.conf /config/

CMD ["-f", "/config/logstash.conf"]
