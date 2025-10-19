#!/usr/bin/env bash
# create_log_output_json_nginx.sh
# Generate NDJSON + plain text synthetic Nginx access logs
# Uses "timestamp" (ISO8601 UTC) instead of "@timestamp"
# Supports -i <nanoseconds> increment per line

set -euo pipefail

usage() {
  cat <<EOF
Usage:
  $(basename "$0") -n <name> -l <lines> -d <directory> [-t <time>] [-i <nanoseconds>]

Writes:
  * NDJSON -> <directory>/<name>.log
  * Plain text -> <directory>/<name>_text.log

Options:
  -n  Base name of the log file (with or without .log)
  -l  Number of lines to generate
  -d  Output directory
  -t  Base time ("now" or "YYYY-MM-DD" or "YYYY-MM-DD HH:MM:SS", UTC)
  -i  Nanoseconds to add per log entry (default 0)
      Example: -i 50 means +50ns each line
EOF
}

NAME=""; NUM_LINES=""; DIR=""; TIME_STR="now"; INCR_NS=0

while getopts ":n:l:d:t:i:h" opt; do
  case "$opt" in
    n) NAME="$OPTARG" ;;
    l) NUM_LINES="$OPTARG" ;;
    d) DIR="$OPTARG" ;;
    t) TIME_STR="$OPTARG" ;;
    i) INCR_NS="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Error: Invalid option -$OPTARG" >&2; usage; exit 1 ;;
    :)  echo "Error: Option -$OPTARG requires an argument." >&2; usage; exit 1 ;;
  esac
done

if [[ -z "${NAME}" || -z "${NUM_LINES}" || -z "${DIR}" ]]; then
  echo "Error: -n, -l, and -d are required." >&2
  usage
  exit 1
fi

case "$NAME" in
  *.log) FILE_JSON="$NAME" ;;
  *)     FILE_JSON="${NAME}.log" ;;
esac

OUT_DIR="${DIR%/}"
OUT_FILE_JSON="${OUT_DIR}/${FILE_JSON}"
BASE_NO_EXT="${FILE_JSON%.log}"
OUT_FILE_TEXT="${OUT_DIR}/${BASE_NO_EXT}_text.log"

mkdir -p "$OUT_DIR"
: > "$OUT_FILE_JSON"
: > "$OUT_FILE_TEXT"

# Resolve base time in epoch seconds (UTC)
if [[ "$TIME_STR" == "now" ]]; then
  BASE_EPOCH=$(date -u +%s)
elif [[ "$TIME_STR" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  BASE_EPOCH=$(date -u -d "${TIME_STR} 00:00:00" +%s)
else
  BASE_EPOCH=$(date -u -d "$TIME_STR" +%s)
fi

echo "Generating ${NUM_LINES} entries:"
echo "  Base UTC time: $(date -u -d @${BASE_EPOCH} +%Y-%m-%dT%H:%M:%S)Z"
echo "  Increment per line: ${INCR_NS} ns"
echo "  NDJSON -> $OUT_FILE_JSON"
echo "  Text   -> $OUT_FILE_TEXT"

awk -v total="${NUM_LINES}" -v fjson="$OUT_FILE_JSON" -v ftext="$OUT_FILE_TEXT" \
    -v base_epoch="${BASE_EPOCH}" -v step_ns="${INCR_NS}" '
function esc(s,    t){t=s; gsub(/\\/, "\\\\", t); gsub(/"/,"\\\"",t); gsub(/\t/,"\\t",t); gsub(/\r/,"\\r",t); gsub(/\n/,"\\n",t); return t}

BEGIN{
  srand()
  methods[1]="GET"; methods[2]="POST"; methods[3]="DELETE"; methods[4]="PUT"
  paths[1]="/"; paths[2]="/index.html"; paths[3]="/login"; paths[4]="/api/data"; paths[5]="/about"
  refs[1]="-"; refs[2]="https://google.com"; refs[3]="https://example.com"; refs[4]="https://bing.com"
  agents[1]="Mozilla/5.0"; agents[2]="curl/7.68.0"; agents[3]="PostmanRuntime/7.32.0"
  statuses[1]=200; statuses[2]=201; statuses[3]=301; statuses[4]=400; statuses[5]=404; statuses[6]=500

  count=0
  while(count < total){
    ns_total = count * step_ns
    sec_offset = int(ns_total / 1e9)
    ns_remainder = ns_total % 1e9

    t = base_epoch + sec_offset
    ts_base = strftime("%Y-%m-%dT%H:%M:%S", t)
    frac = sprintf("%09d", ns_remainder)
    ts_iso = ts_base "." frac "Z"

    ip=int(rand()*255)"."int(rand()*255)"."int(rand()*255)"."int(rand()*255)
    user=(rand()>0.5) ? "user"int(rand()*1000) : "-"
    method=methods[int(rand()*4)+1]
    path=paths[int(rand()*5)+1]
    http_raw="HTTP/1.1"
    http_version="1.1"
    status=statuses[int(rand()*6)+1]
    bytes=int(rand()*5000)+200
    ref=refs[int(rand()*4)+1]
    ua=agents[int(rand()*3)+1]

    json="{"
    json=json"\"log_timestamp\":\""esc(ts_iso)"\","
    json=json"\"client\":{\"ip\":\""esc(ip)"\"},"
    json=json"\"user\":{\"name\":\""esc(user)"\"},"
    json=json"\"http\":{"
      json=json"\"request\":{"
        json=json"\"method\":\""esc(method)"\","
        json=json"\"referrer\":\""esc(ref)"\""
      json=json"},"
      json=json"\"response\":{"
        json=json"\"status_code\":"status","
        json=json"\"body\":{\"bytes\":"bytes"}"
      json=json"},"
      json=json"\"version\":\""esc(http_version)"\""
    json=json"},"
    json=json"\"url\":{\"path\":\""esc(path)"\"},"
    json=json"\"user_agent\":{\"original\":\""esc(ua)"\"}"
    json=json"}"
    print json >> fjson

    req=method" "path" "http_raw
    txt=ip" - "user" [" ts "] \""req"\" "status" "bytes" \""ref"\" \""ua"\""
    gsub(" ts ", ts_iso, txt)
    print txt >> ftext

    count++
  }

  close(fjson); close(ftext)
}
'
echo "✅ Done."


