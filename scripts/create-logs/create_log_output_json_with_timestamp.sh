#!/bin/bash

# Default values
OUTPUT_DIR="./logs"
OUTPUT_NAME="access_log.json"
NUM_LINES=1
APPEND=false
TO_STDOUT=false

WORD_LIST="/usr/share/dict/words"
IP_ADDRESS="127.0.0.1"
IDENT="-"
USERID="alice"

# System utilities
DATE_CMD="/usr/bin/date"
SHUF_CMD="/usr/bin/shuf"
TR_CMD="/usr/bin/tr"
JQ_CMD="/usr/bin/jq"

# Spinner (optional for long runs)
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

# Progress display every 1000 lines
show_progress() {
  local current_line="$1"
  local interval="${2:-1000}"
  if (( current_line % interval == 0 )); then
    printf "\r🔄 %'8d lines generated..." "$current_line"
  fi
}

# Usage
usage() {
  echo "Usage: $0 [-n NUM_LINES] [-d OUTPUT_DIR] [-f OUTPUT_NAME] [-a] [-s]"
  echo "  -n NUM_LINES     Number of log entries to generate (default: 1)"
  echo "  -d OUTPUT_DIR    Output directory (default: ./logs)"
  echo "  -f OUTPUT_NAME   Output file name (default: access_log.json)"
  echo "  -a               Append to output file instead of overwriting"
  echo "  -s               Also print each JSON line to stdout"
  exit 1
}

# Parse args
while getopts ":n:d:f:as" opt; do
  case $opt in
    n) NUM_LINES="$OPTARG" ;;
    d) OUTPUT_DIR="$OPTARG" ;;
    f) OUTPUT_NAME="$OPTARG" ;;
    a) APPEND=true ;;
    s) TO_STDOUT=true ;;
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

# Construct output path
OUTPUT_FILE="$OUTPUT_DIR/$OUTPUT_NAME"
mkdir -p "$OUTPUT_DIR"

# Clear file if not appending
if ! $APPEND; then
  > "$OUTPUT_FILE"
fi

# Generate log lines
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

  # ISO 8601 timestamp
  TIMESTAMP="$($DATE_CMD -u "+%b %d, %Y @ %H:%M:%S.%3N")"

  # HTTP version
  HTTP_VERSION="HTTP/1.1"

  # Random status and size
  HTTP_STATUS=$((RANDOM % 300 + 200))
  RESP_SIZE=$((RANDOM % 9000 + 1000))

  # Build JSON log entry
  json_output=$($JQ_CMD -n \
    --arg ip "$IP_ADDRESS" \
    --arg ident "$IDENT" \
    --arg userid "$USERID" \
    --arg timestamp "$TIMESTAMP" \
    --arg request "\"$METHOD $PATH $HTTP_VERSION\"" \
    --arg status "$HTTP_STATUS" \
    --arg size "$RESP_SIZE" \
    --argjson line "$i" \
    '{
      line: $line,
      ip: $ip,
      ident: $ident,
      userid: $userid,
      timestamp: $timestamp,
      request: $request,
      status: ($status | tonumber),
      size: ($size | tonumber)
    }')

  # Write to file and/or stdout
  echo "$json_output" >> "$OUTPUT_FILE"
  if $TO_STDOUT; then
    echo "$json_output"
  fi
done

# Final newline and summary
echo
echo "✅ Script completed."
echo "✅ Generated $NUM_LINES log entries in $OUTPUT_FILE"
