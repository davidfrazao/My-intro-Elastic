0- clean if needed

delete: 
./data/prometheus/data
./data/grafana/data
./data/data-es01
./data/data-es02
./data/data-es03

1 - run docker compose: ./docker-compose-main/elasticsearch_3_nodes_with_certs

2- check: 
### links
### Promtheus
http://127.0.0.1:9090
### Prometheus - metrics
http://127.0.0.1:9090/metrics
### Grafana 
http://127.0.0.1:3000
create a user: admin pass:admin
### Grafana - metrics
http://127.0.0.1:3000/metrics
### kibana
http://127.0.0.1:5601
user: elastic
password: elastic
### Elastiscearch 
https://127.0.0.1:19202
https://elastic:elastic@127.0.0.1:19200
https://elastic:elastic@127.0.0.1:19201
https://elastic:elastic@127.0.0.1:19202

### Elasticsearch exporter
http://127.0.0.1:9114
### Elasticsearch exporter
http://127.0.0.1:9114/metrics

3- check prometheus scraping
change to time interval

4- add dashboard
Get the ID from https://grafana.com/grafana/dashboards/2322-elasticsearch/ ( datasource as Prometheus)