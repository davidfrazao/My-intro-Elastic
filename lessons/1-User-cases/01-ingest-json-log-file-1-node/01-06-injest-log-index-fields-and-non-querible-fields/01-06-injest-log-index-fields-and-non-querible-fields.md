´´´
# Create a self-contained Python script that performs the same demo as the bash script
script = r"""#!/usr/bin/env python3
"""
script += r"""
"""
script += r"""import argparse
import json
import sys
import time
from typing import Any, Dict, Optional

import requests


def jprint(obj: Any) -> None:
    print(json.dumps(obj, indent=2, sort_keys=False, ensure_ascii=False))


def req(
    method: str,
    url: str,
    json_body: Optional[Dict[str, Any]] = None,
    auth: Optional[requests.auth.AuthBase] = None,
    headers: Optional[Dict[str, str]] = None,
    verify: bool = True,
) -> requests.Response:
    kwargs = {
        "method": method,
        "url": url,
        "headers": headers or {"Content-Type": "application/json"},
        "verify": verify,
        "timeout": 30,
    }
    if json_body is not None:
        kwargs["json"] = json_body
    if auth is not None:
        kwargs["auth"] = auth
    return requests.request(**kwargs)


def wait_for_es(es_url: str, auth, headers, verify: bool, retries: int = 30) -> None:
    print(f"Waiting for Elasticsearch at {es_url} ...")
    for i in range(1, retries + 1):
        try:
            r = req("GET", f"{es_url}/", auth=auth, headers=headers, verify=verify)
            if r.ok:
                print("Elasticsearch is up.")
                return
        except Exception as e:
            pass
        print(f"  retry {i}/{retries} ...")
        time.sleep(1)
    print("ERROR: Elasticsearch did not respond in time.", file=sys.stderr)
    sys.exit(1)


def create_template(es_url: str, auth, headers, verify: bool, template_name: str) -> None:
    print(f"\n1) Creating index template '{template_name}'")
    body = {
        "index_patterns": ["logstash-*"],
        "priority": 200,
        "template": {
            "mappings": {
                "dynamic": True,
                "dynamic_templates": [
                    {
                        "non_declared_fields": {
                            "match_mapping_type": "*",
                            "match": "*",
                            "mapping": {"index": False},
                        }
                    }
                ],
                "properties": {
                    "@timestamp": {"type": "date"},
                    "message": {"type": "text"},
                    "log": {"properties": {"level": {"type": "keyword"}}},
                    "host": {"properties": {"name": {"type": "keyword"}}},
                },
            }
        },
    }
    r = req("PUT", f"{es_url}/_index_template/{template_name}", json_body=body, auth=auth, headers=headers, verify=verify)
    if not r.ok:
        print("Failed to create template:", r.status_code, r.text, file=sys.stderr)
        sys.exit(1)
    jprint(r.json())
    print("Template created.")


def ingest_docs(es_url: str, auth, headers, verify: bool, index_name: str) -> None:
    print(f"\n2) Ingesting demo documents into index '{index_name}'")
    docs = {
        "1": {
            "@timestamp": "2025-10-22T12:00:00Z",
            "message": "User login succeeded",
            "log": {"level": "INFO"},
            "host": {"name": "web01"},
            "app": {"name": "frontend", "version": "1.3.0"},
            "extra_field": "this is not indexed",
        },
        "2": {
            "@timestamp": "2025-10-22T12:01:00Z",
            "message": "Database connection timeout",
            "log": {"level": "ERROR"},
            "host": {"name": "db01"},
            "trace_id": "abc123",
            "details": {"query": "SELECT * FROM users"},
        },
        "3": {
            "@timestamp": "2025-10-22T12:02:00Z",
            "message": "Payment processed",
            "log": {"level": "INFO"},
            "host": {"name": "payments01"},
            "customer_id": 9876,
            "card_type": "VISA",
        },
    }
    for doc_id, body in docs.items():
        r = req("POST", f"{es_url}/{index_name}/_doc/{doc_id}?refresh=true", json_body=body, auth=auth, headers=headers, verify=verify)
        if not r.ok:
            print(f"Failed to index doc {doc_id}:", r.status_code, r.text, file=sys.stderr)
            sys.exit(1)
        jprint(r.json())
    print("Documents ingested.")


def show_mapping(es_url: str, auth, headers, verify: bool, index_name: str) -> None:
    print("\n3) Mapping snapshot (note 'index': false on undeclared fields)")
    r = req("GET", f"{es_url}/{index_name}/_mapping", auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed to get mapping:", r.status_code, r.text, file=sys.stderr)


def field_caps(es_url: str, auth, headers, verify: bool, index_name: str) -> None:
    print("\n4) Field capabilities (searchable/aggregatable)")
    r = req("GET", f"{es_url}/{index_name}/_field_caps?fields=*", auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed to get field caps:", r.status_code, r.text, file=sys.stderr)


def explain_queries(es_url: str, auth, headers, verify: bool, index_name: str) -> None:
    print("\n5) _explain on indexed field (message) — expected: matched=true")
    body = {"query": {"match": {"message": "login succeeded"}}}
    r = req("POST", f"{es_url}/{index_name}/_explain/1", json_body=body, auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed to explain indexed field:", r.status_code, r.text, file=sys.stderr)

    print("\n6) _explain on non-indexed field (app.name) — expected: matched=false")
    body = {"query": {"match": {"app.name": "frontend"}}}
    r = req("POST", f"{es_url}/{index_name}/_explain/1", json_body=body, auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed to explain non-indexed field:", r.status_code, r.text, file=sys.stderr)


def termvectors(es_url: str, auth, headers, verify: bool, index_name: str) -> None:
    print("\n7) _termvectors — indexed 'message'")
    body = {
        "fields": ["message"],
        "term_statistics": True,
        "field_statistics": True,
        "positions": False,
        "offsets": False,
    }
    r = req("POST", f"{es_url}/{index_name}/_termvectors/1", json_body=body, auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed to get termvectors for 'message':", r.status_code, r.text, file=sys.stderr)

    print("\n7b) _termvectors — non-indexed 'app.name' (expected empty term_vectors)")
    body = {"fields": ["app.name"], "term_statistics": True}
    r = req("POST", f"{es_url}/{index_name}/_termvectors/1", json_body=body, auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed to get termvectors for 'app.name':", r.status_code, r.text, file=sys.stderr)


def searches(es_url: str, auth, headers, verify: bool, index_name: str) -> None:
    print("\n8) Search on indexed field log.level:INFO — expected: hits>0")
    body = {"query": {"term": {"log.level": "INFO"}}}
    r = req("POST", f"{es_url}/{index_name}/_search?track_total_hits=true", json_body=body, auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed search on indexed field:", r.status_code, r.text, file=sys.stderr)

    print("\n8b) Search on non-indexed field app.name:frontend — expected: 0 hits")
    body = {"query": {"match": {"app.name": "frontend"}}, "track_total_hits": True}
    r = req("POST", f"{es_url}/{index_name}/_search", json_body=body, auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed search on non-indexed field:", r.status_code, r.text, file=sys.stderr)


def get_source(es_url: str, auth, headers, verify: bool, index_name: str) -> None:
    print("\n9) _source retrieval — non-indexed fields are preserved")
    r = req("GET", f"{es_url}/{index_name}/_doc/1", auth=auth, headers=headers, verify=verify)
    if r.ok:
        jprint(r.json())
    else:
        print("Failed to get _source:", r.status_code, r.text, file=sys.stderr)


def cleanup(es_url: str, auth, headers, verify: bool, index_name: str, template_name: str) -> None:
    print("\nCleanup: deleting index and template")
    r1 = req("DELETE", f"{es_url}/{index_name}", auth=auth, headers=headers, verify=verify)
    print("Delete index:", r1.status_code, r1.text)
    r2 = req("DELETE", f"{es_url}/_index_template/{template_name}", auth=auth, headers=headers, verify=verify)
    print("Delete template:", r2.status_code, r2.text)


def main():
    parser = argparse.ArgumentParser(description="Elasticsearch demo: indexed vs non-indexed fields")
    parser.add_argument("--es-url", default="http://localhost:9200", help="Elasticsearch base URL")
    parser.add_argument("--username", default="elastic", help="Username for basic auth")
    parser.add_argument("--password", default="changeme", help="Password for basic auth")
    parser.add_argument("--index", default="logstash-demo", help="Target index name")
    parser.add_argument("--template-name", default="logstash_strict_mappings_demo", help="Index template name")
    parser.add_argument("--verify-ssl", action="store_true", help="Verify TLS certificates (default: false)")
    parser.add_argument("--api-key", default=None, help="Optional Base64 API key (id:api_key, already base64-encoded)")
    parser.add_argument("--cleanup", action="store_true", help="Delete index and template at the end")
    args = parser.parse_args()

    headers = {"Content-Type": "application/json"}
    auth = requests.auth.HTTPBasicAuth(args.username, args.password)

    if args.api_key:
        headers["Authorization"] = f"ApiKey {args.api_key}"
        # When using API key, ignore basic auth
        auth = None

    verify = args.verify_ssl

    wait_for_es(args.es_url, auth, headers, verify)
    create_template(args.es_url, auth, headers, verify, args.template_name)
    ingest_docs(args.es_url, auth, headers, verify, args.index)
    show_mapping(args.es_url, auth, headers, verify, args.index)
    field_caps(args.es_url, auth, headers, verify, args.index)
    explain_queries(args.es_url, auth, headers, verify, args.index)
    termvectors(args.es_url, auth, headers, verify, args.index)
    searches(args.es_url, auth, headers, verify, args.index)
    get_source(args.es_url, auth, headers, verify, args.index)

    if args.cleanup:
        cleanup(args.es_url, auth, headers, verify, args.index, args.template_name)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted.", file=sys.stderr)
        sys.exit(130)
    except requests.exceptions.RequestException as e:
        print(f"HTTP error: {e}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
"""
´´´

path = "/mnt/data/es_indexed_vs_nonindexed_demo.py"
with open(path, "w") as f:
    f.write(script)

path



Done! Here’s a **self-contained Python script** that sets up the template, ingests example docs, and demonstrates indexed vs non-indexed field behavior:

[Download es_indexed_vs_nonindexed_demo.py](sandbox:/mnt/data/es_indexed_vs_nonindexed_demo.py)

### How to run

```bash
# 1) Install dependency
pip install requests

# 2) Run with defaults (http://localhost:9200, elastic/changeme)
python es_indexed_vs_nonindexed_demo.py

# Or customize:
python es_indexed_vs_nonindexed_demo.py \
  --es-url https://your-es:9200 \
  --username elastic \
  --password 'yourpass' \
  --index logstash-demo \
  --template-name logstash_strict_mappings_demo \
  --verify-ssl \
  # --api-key BASE64_API_KEY   # optional if you prefer API keys
  # --cleanup                  # optional: delete index + template at the end
```

What it does:

1. Creates an **index template** that indexes only declared fields and sets everything else to `"index": false`.
2. Ingests 3 demo documents.
3. Shows the **mapping** and **field capabilities**.
4. Runs `_explain`, `_termvectors`, and `_search` calls to prove:

   * Indexed fields match searches.
   * Non-indexed fields don’t match.
   * Non-indexed fields are still present in `_source`.

Want me to tailor the script to your TLS setup (custom CA file, mTLS, or Elastic Cloud)?

