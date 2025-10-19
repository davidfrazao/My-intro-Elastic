
chmod +x http_access_log_simulator_output_json.sh

# log with elasticsearch timespace - unstructure log
```
./create_log_output_json_with_timestamp_unstructure_log.sh -n 10000 -d ../../output-log-json/10.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 25000 -d ../../output-log-json/25.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 50000 -d ../../output-log-json/50.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 75000 -d ../../output-log-json/75.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 100000 -d ../../output-log-json/100.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 200000 -d ../../output-log-json/200.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 2500000 -d ../../output-log-json/250.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 5000000 -d ../../output-log-json/500.000/timestamp_yes_unstructure_log
./create_log_output_json_with_timestamp_unstructure_log.sh -n 10000000 -d ../../output-log-json/1.000.000/timestamp_yes_unstructure_log
```



# log with elasticsearch timespace - ISO8601
```
./create_log_output_json_with_timestamp_ISO8601.sh -n 10000 -d ../../output-log-json/10.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 25000 -d ../../output-log-json/25.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 50000 -d ../../output-log-json/50.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 75000 -d ../../output-log-json/75.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 100000 -d ../../output-log-json/100.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 200000 -d ../../output-log-json/200.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 2500000 -d ../../output-log-json/250.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 5000000 -d ../../output-log-json/500.000/timestamp_yes_ISO8601
./create_log_output_json_with_timestamp_ISO8601.sh -n 10000000 -d ../../output-log-json/1.000.000/timestamp_yes_ISO8601
```

# log with elasticsearch timespace - ISO8601 - -single-line-compact-JSON
```
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 10000 -d ../../output-log-json/10.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 25000 -d ../../output-log-json/25.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 50000 -d ../../output-log-json/50.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 75000 -d ../../output-log-json/75.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 100000 -d ../../output-log-json/100.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 200000 -d ../../output-log-json/200.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 2500000 -d ../../output-log-json/250.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 5000000 -d ../../output-log-json/500.000/timestamp_yes_ISO8601-single-line-compact-JSON
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 10000000 -d ../../output-log-json/1.000.000/timestamp_yes_ISO8601-single-line-compact-JSON
```~


# log with timespace
```
./create_log_output_json_with_timestamp.sh -n 10000 -d ../../output-log-json/10.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 25000 -d ../../output-log-json/25.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 50000 -d ../../output-log-json/50.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 75000 -d ../../output-log-json/75.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 100000 -d ../../output-log-json/100.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 200000 -d ../../output-log-json/200.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 2500000 -d ../../output-log-json/250.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 5000000 -d ../../output-log-json/500.000/timestamp_yes
./create_log_output_json_with_timestamp.sh -n 10000000 -d ../../output-log-json/1.000.000/timestamp_yes
```

# log without timespace
```
./create_log_output_json_without_timestamp.sh -n 10000 -o ../../output-log-json/10.000/timestamp_no/access_log.json
./create_log_output_json_without_timestamp.sh -n 25000 -o ../../output-log-json/25.000/timestamp_no/access_log.json
./create_log_output_json_without_timestamp.sh -n 50000 -o ../../output-log-json/50.000/timestamp_no/access_log.json
./create_log_output_json_without_timestamp.sh -n 75000 -o ../../output-log-json/75.000/timestamp_no/access_log.json
./create_log_output_json_without_timestamp.sh -n 100000 -o ../../output-log-json/100.000/timestamp_no/access_log.json
./create_log_output_json_without_timestamp.sh -n 200000 -o ../../output-log-json/200.000/timestamp_no/access_log.json
./create_log_output_json_without_timestamp.sh -n 5000000 -o ../../output-log-json/500.000/timestamp_no/access_log.json
./create_log_output_json_without_timestamp.sh -n 10000000 -o ../../output-log-json/1.000.000/timestamp_no/access_log.json
```

# ngnix
chmod +x create_log_output_json_nginx.sh
./create_log_output_json_nginx.sh  -n access.log -l 10000 -d../../output-log-json/10.000/nginx

./create_log_output_json_nginx.sh  -n access.log -l 50000 -d../../output-log-json/50.000/nginx

./create_log_output_json_nginx.sh  -n access.log -l 100000 -d../../output-log-json/100.000/nginx