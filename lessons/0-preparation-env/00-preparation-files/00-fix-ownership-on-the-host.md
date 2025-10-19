fix ownership on the host

mkdir -p ./data
sudo chown -R $(id -u):$(id -g) ./data
# if group write needed:
chmod -R g+rwX ./data


