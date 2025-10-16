#!/usr/bin/env sh
set -eu

API_DIR="/usr/share/nginx/html/api"
DEFAULTS_JSON="${API_DIR}/default_clusters.json"

mkdir -p "$API_DIR"

write_defaults() {
  # $1 = JSON (either bare array OR full object)
  CONTENT="$1"

  # If the content starts with “[”, wrap it into { "clusters": [...] }
  case "$(printf '%s' "$CONTENT" | sed -e 's/^[[:space:]]*//')" in
    \[*)
      printf '{ "clusters": %s }\n' "$CONTENT" > "$DEFAULTS_JSON"
      ;;
    \{*)
      # Assume it's already an object (ideally with "clusters")
      printf '%s\n' "$CONTENT" > "$DEFAULTS_JSON"
      ;;
    *)
      echo "[elasticvue] ERROR: ELASTICVUE_CLUSTERS must be JSON (array or object)" >&2
      exit 1
      ;;
  esac

  chown nginx:nginx "$DEFAULTS_JSON" || true
  chmod 0644 "$DEFAULTS_JSON" || true
  echo "[elasticvue] Wrote defaults to ${DEFAULTS_JSON}"
}

# Priority 1: explicit file path provided by user
if [ "${ELASTICVUE_CLUSTERS_FILE-}" ] && [ -f "${ELASTICVUE_CLUSTERS_FILE}" ]; then
  write_defaults "$(cat "${ELASTICVUE_CLUSTERS_FILE}")"

# Priority 2: env var with JSON
elif [ "${ELASTICVUE_CLUSTERS-}" ]; then
  # Trim leading/trailing whitespace just in case
  CLUSTERS_TRIMMED="$(printf '%s' "$ELASTICVUE_CLUSTERS" | awk '{$1=$1};1')"
  write_defaults "$CLUSTERS_TRIMMED"

# Otherwise: do nothing (no defaults)
else
  echo "[elasticvue] No ELASTICVUE_CLUSTERS or ELASTICVUE_CLUSTERS_FILE provided; skipping defaults"
fi

# Hand off to nginx
exec "$@"

