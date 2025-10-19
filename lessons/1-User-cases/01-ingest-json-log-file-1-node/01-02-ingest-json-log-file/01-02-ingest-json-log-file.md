case: simple
- ingest a log full json
- no template 
- no ILM
- @timestamp = log_timestamp from the log
- cluster - 1

Action: 
create dataview
01-02-ingest-json

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
# URL-cerebro 
http://127.0.0.1:9000
# URL-elasticvue
http://127.0.0.1:8081