
0- clean if needed

delete: 
./data/prometheus/data
./data/grafana/data
./data/elasticsearch

1 - run docker compose: ./docker-compose-main/elasticsearch_1_node_no_pass

2- check: 
### links
### Promtheus
http://127.0.0.1:59090
### Prometheus - metrics
http://127.0.0.1:59090/metrics
### Grafana 
http://127.0.0.1:53000
create a user: admin pass:admin
### Grafana - metrics
http://127.0.0.1:53000/metrics
### kibana
http://127.0.0.1:55601
### Elastiscearch 
http://127.0.0.1:58881
### Elasticsearch exporter
http://127.0.0.1:59114
### Elasticsearch exporter
http://127.0.0.1:59114/metrics

3- check prometheus scraping
change to time interval

4- add dashboard
Get the ID from https://grafana.com/grafana/dashboards/2322-elasticsearch/ ( datasource as Prometheus)
