---
source: https://itnext.io/how-do-open-source-solutions-for-logs-work-elasticsearch-loki-and-victorialogs-9f7097ecbc2f
tags:
  - how_it_work
  - elasticsearch
---
# How does Elasticsearch store and query logs?

Elasticsearch assigns an unique **ID** per every ingested log entry (this may be an offset in the file where plain log entries are stored). Then it splits every log field into words. For example, `message` field with the value `error details: name = ErrorInfo` is split into `error`, `details`, `name` and `ErrorInfo` words (aka tokens). Then it persists these tokens in the [inverted index](https://en.wikipedia.org/wiki/Inverted_index) — this is a mapping from `(field_name; token)` to log entry `ID`. For example, the `message` field above is transformed into four entries in the inverted index:

- `(message; error)` -> `ID`
- `(message; details)` -> `ID`
- `(message; name)` -> `ID`
- `(message; ErrorInfo)` -> `ID`

The typical token length is around 5–10 bytes. So we can estimate that Elasticsearch needs to create around 125 entries in the inverted index per each ingested log entry with `1KiB` length. So Elasticsearch creates `125 billions` of entries in the inverted index for a billion of logs with `1KiB` each. Inverted index entries for the same `(field_name; token)` pairs are usually stored in a compact form known as `postings`:

`(field_name; token)` -> `[ID_1, ID_2, … ID_N]`

For example, all the tokens for the field `kubernetes_container_name=fluentbit` are compacted eventually into a single inverted index entry across all the logs with this field:

`(kubernetes_container_name; fluentbit) -> [ID_1, ID_2, … ID_N]`

If the number of such logs equals 125 millions, then the `[ID_1, ID_2, … ID_N]` list contains 125 millions of entries. Every ID is usually a 64-bit integer, so 125 millions of entries occupy `125M*8 = 1GB`.

Then the size of the inverted index for storing a billion of `1KiB` logs with 125 tokens each equals to at least `1B*125*8 = 1TB` (not counting the storage needed for `(field_name; token)` pairs). Elasticsearch needs to store the original logs , so they could be shown in query results. A billion of `1KiB` logs needs `1B*1KiB = 1TiB` of storage space. So the total needed storage space equals to `1TB + 1TiB = 2TiB` . Elasticsearch may apply some compression to inverted index via [roaring bitmaps](https://roaringbitmap.org/). It also may compress the original logs. This may reduce the required disk space by a few times, but it is still too big :==(==

Elasticsearch uses the inverted index for fast full-text search. When you search for some word (aka token) at some field, then it instantly locates postings for the `(field_name; token)` pair in the inverted index using [binary search](https://en.wikipedia.org/wiki/Binary_search) over sorted by `(field_name; token)` postings, then the original log entries are located by their IDs and read from the storage one-by-one. That’s why Elasticsearch shows such an outstanding query performance for full-text search!