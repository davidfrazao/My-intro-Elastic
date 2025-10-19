#!/usr/bin/env bash
# create_log_output_json_nginx.sh
# Generate ECS-native NDJSON for synthetic Nginx access logs
# Also writes a plain-text "combined" log for convenience.

set -euo pipefail

usage() {
  cat <<EOF
Usage:
  $(basename "$0") -n <name> -l <lines> -d <directory>

Writes:
  * NDJSON (ECS fields) -> <directory>/<name>.log
  * Plain text combined -> <directory>/<name>_text.log

ECS fields emitted per event:
  client.ip
  user.name
  http.request.method
  url.path
  http.version                (e.g. "1.1")
  http.request.referrer
  user_agent.original
  http.response.status_code   (integer)
  http.response.body.bytes    (integer)
EOF
}

NAME=""; NUM_LINES=""; DIR=""

while getopts ":n:l:d:h" opt; do
  case "$opt" in
    n) NAME="$OPTARG" ;;
    l) NUM_LINES="$OPTARG" ;;
    d) DIR="$OPTARG" ;;
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

echo "Generating ${NUM_LINES} entries:"
echo "  ECS NDJSON   -> $OUT_FILE_JSON"
echo "  Plain text   -> $OUT_FILE_TEXT"

awk -v total="${NUM_LINES}" -v fjson="$OUT_FILE_JSON" -v ftext="$OUT_FILE_TEXT" '
# JSON-safe string escape (portable)
function esc(s,    t){t=s; gsub(/\\/, "\\\\", t); gsub(/"/,"\\\"",t); gsub(/\t/,"\\t",t); gsub(/\r/,"\\r",t); gsub(/\n/,"\\n",t); return t}

BEGIN{
  srand()
  # Pools
  methods[1]="GET"; methods[2]="POST"; methods[3]="DELETE"; methods[4]="PUT"
  paths[1]="/"; paths[2]="/index.html"; paths[3]="/login"; paths[4]="/api/data"; paths[5]="/about"
  refs[1]="-"; refs[2]="https://google.com"; refs[3]="https://example.com"; refs[4]="https://bing.com"
  agents[1]="Mozilla/5.0"; agents[2]="curl/7.68.0"; agents[3]="PostmanRuntime/7.32.0"
  statuses[1]=200; statuses[2]=201; statuses[3]=301; statuses[4]=400; statuses[5]=404; statuses[6]=500

  count=0
  while(count < total){
    # Random IP and user
    ip=int(rand()*255)"."int(rand()*255)"."int(rand()*255)"."int(rand()*255)
    user=(rand()>0.5) ? "user"int(rand()*1000) : "-"

    # Request parts
    method=methods[int(rand()*4)+1]
    path=paths[int(rand()*5)+1]
    http_raw="HTTP/1.1"
    http_version="1.1"   # ECS expects numeric string

    status=statuses[int(rand()*6)+1]
    bytes=int(rand()*5000)+200
    ref=refs[int(rand()*4)+1]
    ua=agents[int(rand()*3)+1]

    # --- ECS NDJSON object ---
    json="{"
    json=json"\"client\":{\"ip\":\""esc(ip)"\"},"
    json=json"\"user\":{\"name\":\""esc(user) "\"},"
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

    # --- Plain-text combined (for reference) ---
    t=systime() - int(rand()*86400)
    ts=strftime("%d/%b/%Y:%H:%M:%S %z", t)
    req=method" "path" "http_raw
    txt=ip" - "user" ["ts"] \""req"\" "status" "bytes" \""ref"\" \""ua"\""
    print txt >> ftext

    count++
  }

  close(fjson); close(ftext)
}
'
echo "✅ Done."