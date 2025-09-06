# 🔹 Typical workflow for Elasticsearch + Kibana

0. **Build**
   ```bash
   docker-compose -f docker-compose-elasticvue.yml build elasticvue
   ```

1. **First run (watch everything):**

   ```bash
   docker-compose -f docker-compose-elasticvue.yml up
   docker-compose -f docker-compose-elasticvue.yml up -d --force-recreate
   ```

   → verify certs/passwords bootstrap correctly, check cluster health.

2. **Switch to background mode:**

   ```bash
   docker-compose -f docker-compose-elasticvue.yml up -d
   ```

3. **Check logs if needed:**

   ```bash
   docker-compose logs -f es01
   ```

4. **Pause the cluster but keep data:**

   ```bash
   docker-compose stop
   ```

5. **Full cleanup (dangerous! wipes data):**

   ```bash
   docker-compose -f docker-compose-elasticvue.yml down -v
   ```

---