#!/usr/bin/env bash

## Variables

PRIVATE_IP=$(hostname -i)
PUBLIC_IP=$(curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
VAULT_ZIP="${tpl_vault_zip_file}"

##--------------------------------------------------------------------
## Install Vault

logger "Downloading Vault"
sudo apt-get install -y unzip libtool libltdl-dev
curl -s -L -o ~/vault.zip $${VAULT_ZIP}
sudo unzip ~/vault.zip
sudo install -c -m 0755 vault /usr/bin


sudo mkdir -pm 0755 ${tpl_vault_path}/data
sudo chmod -R a+rwx ${tpl_vault_path}/data

sudo tee ${tpl_vault_path}/vault.hcl <<EOF
storage "raft" {
  path    = "${tpl_vault_path}/data"
  node_id = "${tpl_vault_node_name}"

  retry_join {
    auto_join        = "provider=gce tag_value=${tpl_vault_tag}"
    auto_join_scheme = "http"
  }
}

listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "0.0.0.0:8201"
  tls_disable      = true
}

seal "gcpckms" {
  project     = "${tpl_vault_project}"
  region      = "global"
  key_ring    = "${tpl_vault_key_ring}"
  crypto_key  = "${tpl_vault_crypto_key}"
}

api_addr      = "http://$${PUBLIC_IP}:8200"
cluster_addr  = "http://$${PRIVATE_IP}:8201"
disable_mlock = true
ui=true
EOF


sudo echo -e 'export VAULT_ADDR="http://127.0.0.1:8200"\nexport VAULT_SKIP_VERIFY=true\n' >  /etc/profile.d/vault.sh
source /etc/profile.d/vault.sh

/usr/bin/vault server -config=${tpl_vault_path}/vault.hcl -log-level=trace &> ${tpl_vault_path}/vault.log &

