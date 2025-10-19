case: simple
- ingest a log full json
- yes template 
- yes ILM
- @timestamp = log_timestamp from the log
- cluster - 1

Action:
Before create a index template 
```
{
  "template": {
    "settings": {
      "index": {
        "lifecycle": {
          "name": "ILM-1-Min",
          "rollover_alias": "01-05-ingest-json-log-file"
        },
        "routing": {
          "allocation": {
            "include": {
              "_tier_preference": "data_content"
            }
          }
        },
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    },
    "aliases": {
      "01-05-ingest-json-log": {
        "is_write_index": true
      }
    },
    "mappings": {}
  }
}
```

create dataview
01-05-ingest-json

logstash 

  sleep {
    time => 0.1        # 0.1 seconds = 100 ms
    every => 1          # sleep every event (can change to N to sleep every Nth event)
  }
  



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