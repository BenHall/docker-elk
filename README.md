# docker-elk

1) Use `docker-compose up -d` to start ELK

2) To try Logspout, run `create-test-data-logspout.sh`. This will start logspout and generate test data.

3) For Gelf, run `create-test-data.sh` and it will use the Docker Log Driver.

4) Visit Kibana dashboard to see the logs. Kibana runs on port _5601_.

5) It will ask you to create an index. Select the dropdown and select timestamp. 

Try this on Katacoda at https://www.katacoda.com/courses/docker-production/launch-elk-aggregate-container-logs
