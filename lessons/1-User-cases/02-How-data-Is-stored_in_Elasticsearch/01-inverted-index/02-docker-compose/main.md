---
tags:
  - inverted-index
---
can i use Luke application to see the inverted index ob elasticsearch ?

Yes! Here's a working **Docker Compose setup** that includes:

1. **Elasticsearch** (single-node)
    
2. **Luke (Apache Lucene Index Browser)** via a GUI container using X11
    

> ⚠️ Luke does **not have an official Docker image**. So we'll use an **X11-enabled GUI container** and manually run the Luke JAR.

---

## ✅ What You'll Get

- Elasticsearch container that stores Lucene indices
    
- GUI container with OpenJDK + Luke installed
    
- You can browse Lucene segment files from Elasticsearch using Luke
    

---

## 🐳 `docker-compose.yml`

```yaml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.14.0
    container_name: es01
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - esdata:/usr/share/elasticsearch/data

  luke:
    image: dorowu/ubuntu-desktop-lxde-vnc
    container_name: luke
    ports:
      - "5901:5901"       # VNC
      - "6901:6901"       # noVNC (browser-based GUI)
    environment:
      - VNC_PASSWORD=password
    volumes:
      - ./luke:/home/ubuntu/luke
      - esdata:/mnt/esdata:ro   # Mount Elasticsearch Lucene files (read-only)
    command: startlxde

volumes:
  esdata:
```

---

## 📁 Directory Structure

```
project-root/
│
├── docker-compose.yml
└── luke/
    └── luke.jar  ← download this manually (see below)
```

---

## 📥 Step-by-Step Setup

### 1. ✅ Download Luke JAR

Download the latest Luke JAR from:

🔗 [https://github.com/DmitryKey/luke/releases](https://github.com/DmitryKey/luke/releases)

Place it in `./luke/luke.jar` inside your project.

---

### 2. 🚀 Start the Stack

```bash
docker-compose up -d
```

---

### 3. 🌐 Access Luke GUI

Open your browser:

```
http://localhost:6901/
```

- Password: `password`
    
- This opens a full Linux GUI in your browser
    
- Open a terminal inside the GUI and run:
    

```bash
java -jar /root/luke/luke.jar
```

Then:

- Click “Open Index”
    
- Navigate to `/mnt/esdata/nodes/0/indices/` and find your index UUID
    
- Go inside `0/index` and select that directory
    

> If the folder is empty, index something in Elasticsearch first.

---

### 4. 🧪 Index Sample Doc

```
http://localhost:5601/
```

Use curl or Kibana Dev Tools:

```bash
POST /my-index/_doc
{
  "message": "The quick brown fox jumps over the lazy dog"
}
```

Now refresh Luke and you should see the terms.

---

## 🧼 Cleanup

```bash
docker-compose down -v
```

---

Let me know if you want to:

- Add Kibana
    
- Use a local file explorer instead of GUI-in-container
    
- Or browse segment files on your host (with native Luke) instead of Docker