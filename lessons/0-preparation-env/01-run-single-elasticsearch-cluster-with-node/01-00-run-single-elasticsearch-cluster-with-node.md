
0- clean if needed

delete: 
./data/prometheus/data
./data/grafana/data

1 - run docker compose: ./docker-compose-main/elasticsearch_1_node_no_pass

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
http://127.0.0.1:8888
### Elastiscearch 
http://127.0.0.1:8881
### Elasticsearch exporter
http://127.0.0.1:9114
### Elasticsearch exporter
http://127.0.0.1:9114/metrics

3- check prometheus scraping
change to time interval

4- add dashboard
Get the ID from https://grafana.com/grafana/dashboards/2322-elasticsearch/ ( datasource as Prometheus)
