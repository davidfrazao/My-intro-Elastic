#!/bin/bash

# Default values
OUTPUT_FILE="access_log.json"
WORD_LIST="/usr/share/dict/words"
IP_ADDRESS="127.0.0.1"
IDENT="-"
USERID="alice"

# Absolute paths for system utilities
DATE_CMD="/usr/bin/date"
SHUF_CMD="/usr/bin/shuf"
TR_CMD="/usr/bin/tr"
JQ_CMD="/usr/bin/jq"

# Usage
usage() {
    echo "Usage: $0 [-n NUM_LINES] [-o OUTPUT_FILE]"
    echo "  -n NUM_LINES     Number of log entries to generate (default: 1)"
    echo "  -o OUTPUT_FILE   Output file path (default: $OUTPUT_FILE)"
    exit 1
}

# Spinner function
spinner() {
  local spin_chars='/-\|'
  local delay=0.1
  while true; do
    for ((i = 0; i < ${#spin_chars}; i++)); do
      printf "\r%c" "${spin_chars:i:1}"
      sleep $delay
    done
  done
}

# Progress display function (fixed-width)
show_progress() {
  local current_line="$1"
  local interval="${2:-1000}"

  if (( current_line % interval == 0 )); then
    printf "\r🔄 %'8d lines generated..." "$current_line"
  fi
}


NUM_LINES=1


# Parse args
while getopts ":n:o:" opt; do
  case $opt in
    n) NUM_LINES="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    *) usage ;;
  esac
done

# Validate
if ! [[ "$NUM_LINES" =~ ^[0-9]+$ ]]; then
    echo "Error: NUM_LINES must be a positive integer."
    exit 1
fi

# Check word list
if [ ! -f "$WORD_LIST" ]; then
    echo "Missing word list at $WORD_LIST"
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"
> "$OUTPUT_FILE"

# Clear output
> "$OUTPUT_FILE"

for ((i = 1; i <= NUM_LINES; i++)); do

    show_progress "$i"
    
    # Random method
    if (( RANDOM % 2 )); then
        METHOD="GET"
    else
        METHOD="POST"
    fi

    # Random path
    RAW_PATH=$($SHUF_CMD -n 1 "$WORD_LIST" | $TR_CMD '[:upper:]' '[:lower:]' | $TR_CMD -cd '[:alnum:]')
    PATH="/$RAW_PATH/index.html"

   

    # HTTP version
    HTTP_VERSION="HTTP/1.1"

    # HTTP status and size
    HTTP_STATUS=$((RANDOM % 300 + 200))
    RESP_SIZE=$((RANDOM % 9000 + 1000))

    # Write JSON log
    $JQ_CMD -n \
        --arg ip "$IP_ADDRESS" \
        --arg ident "$IDENT" \
        --arg userid "$USERID" \
        --arg request "\"$METHOD $PATH $HTTP_VERSION\"" \
        --arg status "$HTTP_STATUS" \
        --arg size "$RESP_SIZE" \
        --argjson line "$i" \
        '{
            line: $line,
            ip: $ip,
            ident: $ident,
            userid: $userid,
            request: $request,
            status: ($status | tonumber),
            size: ($size | tonumber)
        }' >> "$OUTPUT_FILE"
done

# Newline for clean output
echo
echo "✅ Script completed."
echo "✅ Generated $NUM_LINES JSON-formatted access log entries in $OUTPUT_FILE"

