Create the docker network 
   ```DOCKER
   docker network create \
    --driver bridge \
    --subnet 172.26.0.0/16 \
    elk-docker
   ```