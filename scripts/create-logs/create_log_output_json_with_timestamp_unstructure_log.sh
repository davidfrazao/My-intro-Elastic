#!/bin/bash

# Default values
OUTPUT_DIR="./logs"
OUTPUT_NAME="access_log.txt"
NUM_LINES=1
APPEND=false
TO_STDOUT=false

IP_ADDRESS="127.0.0.1"

# System utilities
DATE_CMD="/usr/bin/date"

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
  echo "  -f OUTPUT_NAME   Output file name (default: access_log.txt)"
  echo "  -a               Append to output file instead of overwriting"
  echo "  -s               Also print each log line to stdout"
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

  # Timestamp
  TIMESTAMP="$($DATE_CMD "+%Y-%m-%d %H:%M:%S")"

  # Log level
  LOG_LEVEL="INFO"

  # Simulated user ID
  USER_ID=$((RANDOM % 100000))

  # Construct log message
  MESSAGE="User $USER_ID logged in from $IP_ADDRESS"

  # Final log line
  log_line="[$TIMESTAMP] $LOG_LEVEL: $MESSAGE"

  # Write to file and/or stdout
  echo "$log_line" >> "$OUTPUT_FILE"
  if $TO_STDOUT; then
    echo "$log_line"
  fi
done

# Final newline and summary
echo
echo "✅ Script completed."
echo "✅ Generated $NUM_LINES log entries in $OUTPUT_FILE"

