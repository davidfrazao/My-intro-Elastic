Got it 👍 — this `command:` section in your **Elasticsearch Docker Compose** is basically a **bootstrap script** that prepares TLS certificates, permissions, and user passwords before starting Elasticsearch. Let’s break it down step by step:

---

### 🔹 1. Validate required environment variables

```bash
if [ x${ELASTIC_PASSWORD} == x ]; then
  echo "Set the ELASTIC_PASSWORD environment variable in the .env file";
  exit 1;
elif [ x${KIBANA_PASSWORD} == x ]; then
  echo "Set the KIBANA_PASSWORD environment variable in the .env file";
  exit 1;
fi;
```

* Ensures that `ELASTIC_PASSWORD` (for the `elastic` superuser) and `KIBANA_PASSWORD` (for Kibana’s `kibana_system` user) are set in your `.env`.
* If missing, the container exits immediately.

---

### 🔹 2. Create a **Certificate Authority (CA)** if missing

```bash
if [ ! -f config/certs/ca.zip ]; then
  echo "Creating CA";
  bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
  unzip config/certs/ca.zip -d config/certs;
fi;
```

* Runs `elasticsearch-certutil ca` to generate a **self-signed CA**.
* Extracts it to `config/certs/ca/ca.crt` and `ca.key`.

---

### 🔹 3. Generate **node certificates** if missing

```bash
if [ ! -f config/certs/certs.zip ]; then
  echo "Creating certs";
  echo -ne \
  "instances:\n"\
  "  - name: es01\n"\
  "    dns:\n"\
  "      - es01\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  ...
  > config/certs/instances.yml;

  bin/elasticsearch-certutil cert --silent --pem \
    -out config/certs/certs.zip \
    --in config/certs/instances.yml \
    --ca-cert config/certs/ca/ca.crt \
    --ca-key config/certs/ca/ca.key;

  unzip config/certs/certs.zip -d config/certs;
fi;
```

* Writes an **instances.yml** file describing certificates for:

  * `es01`, `es02`, `es03` (your Elasticsearch nodes)
  * DNS names: container names + `localhost`
  * IP: `127.0.0.1`
* Uses the CA to sign node certificates for TLS.
* Extracts the certs into `config/certs`.

---

### 🔹 4. Set file permissions

```bash
chown -R root:root config/certs;
find . -type d -exec chmod 750 {} \;;
find . -type f -exec chmod 640 {} \;;
```

* Certificates should only be readable by Elasticsearch (running as non-root user).
* Directories = `750` (owner rwx, group rx).
* Files = `640` (owner rw, group r, others none).

---

### 🔹 5. Wait for Elasticsearch availability

```bash
until curl -s --cacert config/certs/ca/ca.crt https://es01:9200 | grep -q "missing authentication credentials"; do sleep 30; done;
```

* Polls `https://es01:9200` until Elasticsearch is up.
* Checks for the `missing authentication credentials` response, which means TLS works but auth is required → good sign.

---

### 🔹 6. Set Kibana’s system user password

```bash
until curl -s -X POST --cacert config/certs/ca/ca.crt \
  -u "elastic:${ELASTIC_PASSWORD}" \
  -H "Content-Type: application/json" \
  https://es01:9200/_security/user/kibana_system/_password \
  -d "{\"password\":\"${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do sleep 10; done;
```

* Uses the `elastic` superuser to set the `kibana_system` user’s password via Elasticsearch Security API.
* Retries until successful.

---

### 🔹 7. Completion

```bash
echo "All done!";
```

---

✅ **Summary**:
This script **automates TLS setup and secure user bootstrapping** in your multi-node Elasticsearch cluster.
It:

1. Validates required passwords.
2. Creates a CA and node certs (only once).
3. Fixes permissions.
4. Waits for Elasticsearch to start.
5. Configures the `kibana_system` user password so Kibana can authenticate.


