case: simple
- ingest a log full json
- no template 
- no ILM
- @timestamp = log_timestamp from the log
- cluster - 1
- use a logstash template
Action:
create dataview
02-01-ingest-json

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