# My-intro-Elastic
Elasticsearch training 

![Attention](./images/im_progress.png)

### Requirements:
OS:
- OS : Windows 11
- PC with 16 Gb RAM

### Please Install 
- WSL Ubuntu (ubuntu 24.04 )
  
- Update packages
  ```
  sudo apt update
  sudo apt upgrade -y
  ```
- Docker in WSL - install
  ```
  sudo apt install docker-ce
  ```
- Docker in WSL - verify
  ```
  sudo systemctl status docker
  or
  docker --version
  or 
  docker version
  ```

- Docker compose - install 
  ```
  sudo apt install docker-compose
  ```
  - After that install:
        Use docker compose up (✅ new plugin)

- Docker compose - Verify 
  ```
  docker-compose --version
  or 
  docker compose version # new plugin
  ```


Vscode:

- Extentions: Importantes
    - [ms-vscode-containers](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
    - [ms-vscode-remote-wsl](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
    - [ms-vscode-excalidraw-editor](https://marketplace.visualstudio.com/items?itemName=pomdtr.excalidraw-editor)
    - [ms-vscode-open-folder-in-new-vscode](https://marketplace.visualstudio.com/items?itemName=rajratnamaitry.open-folder-in-new-vscode)
    - [ms-vscode-code-runner](https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

- Extention: Extra
    - [vscode-peacock](https://marketplace.visualstudio.com/items?itemName=johnpapa.vscode-peacock)
    - [HashiCorp.terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
 
- Extention: Python
    - [ms-python.python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
    - [ms-python.debugpy](https://marketplace.visualstudio.com/items?itemName=ms-python.debugpy)
    - [ms-python.vscode-pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
    - [ms-python.vscode-python-envs](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-python-envs)

# During 
- 6 to 7 Hours

## 01-01 - lesson - 0-preparation-env 

- How to run a Elasticseatch docker image - One node.
- How to config some parameters in Elasticsearch.
- Tools to interact with Elasticsearch.
    - Kibana
    - Cerebro 
    - ElasticVue
    - grafana
    - Elasticsearch exporter

## 01-02 - lesson - 1-User-cases


## [02 - Function diagram of data flux as logs](./lessons/02-Function-diagram-of-data-flux-as-logs.md)


![Log-flow](./images/log_flow.png)

## 03 - How to write into Elasticsearch

Overall diagram.

![Elastic-model](./images/elastic-model.png)

