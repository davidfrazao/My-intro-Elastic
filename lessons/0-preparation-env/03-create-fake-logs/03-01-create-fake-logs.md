1- open terminal on ./scripts/create-lokgs on Vscode

2- delete /output-log-json/1.000

# log with elasticsearch timespace - unstructure log
```
./create_log_output_json_with_timestamp_unstructure_log.sh -n 1000 -d ../../output-log-json/1.000/timestamp_yes_unstructure_log

```

# log with elasticsearch timespace - ISO8601
```
./create_log_output_json_with_timestamp_ISO8601.sh -n 1000 -d ../../output-log-json/1.000/timestamp_yes_ISO8601

```

# log with elasticsearch timespace - ISO8601 - -single-line-compact-JSON
```
./create_log_output_json_with_timestamp_ISO8601-single-line-compact-JSON.sh -n 1000 -d ../../output-log-json/1.000/timestamp_yes_ISO8601-single-line-compact-JSON



# log with timespace
```
./create_log_output_json_with_timestamp.sh -n 1000 -d ../../output-log-json/1.000/timestamp_yes

```

# log without timespace
```
./create_log_output_json_without_timestamp.sh -n 1000 -o ../../output-log-json/1.000/timestamp_no/access_log.json
