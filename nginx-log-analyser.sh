#!/usr/bin/env bash

set -o pipefail

LOG_FILE="$1"

if [ -z "$LOG_FILE" ]; then
  echo "Usage: $0 <nginx-access.log>"
  exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
  echo "Error: file not found: $LOG_FILE"
  exit 1
fi

for cmd in awk sort uniq head; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command not found: $cmd"
    exit 1
  fi
done

print_top() {
  local title="$1"
  local field_cmd="$2"

  echo
  echo "$title"
  eval "$field_cmd" | sort | uniq -c | sort -nr | head -5 | awk '{count=$1; $1=""; sub(/^ /,""); print $0 " - " count " requests"}'
}

print_top "Top 5 IP addresses with the most requests:" \
  "awk '{print \$1}' '$LOG_FILE'"

print_top "Top 5 most requested paths:" \
  "awk -F'\"' '{split(\$2, req, \" \"); print req[2]}' '$LOG_FILE'"

print_top "Top 5 response status codes:" \
  "awk -F'\"' '{print \$3}' '$LOG_FILE' | awk '{print \$1}'"

print_top "Top 5 user agents:" \
  "awk -F'\"' '{print \$6}' '$LOG_FILE'"
