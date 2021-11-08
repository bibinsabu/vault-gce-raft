#-------------------------------------------------------------------------------------------
# Required:
#    * gcloud-project - set it to your GCP project name to provision cloud resources
#    * account_file_path - the full path to your Cloud IAM service account file location
#-------------------------------------------------------------------------------------------
gcloud-project           = "sinuous-moment-246205"
account_file_path        = "/mnt/c/Users/bibin/Desktop/Learning/Vault/GCP-key/sinuous-moment-246205-a985fd7a710b.json"
gcloud-region            = "us-central1"
gcloud-zone              = ["us-central1-a", "us-central1-b", "us-central1-c"]
key_ring                 = "vault5"
crypto_key               = "vault-unseal-key"
keyring_location         = "global"
machine_type             = "e2-micro"
network-tag              = "vault-server"
vault_zip_file           = "https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip"
vault_server_private_ips = ["10.128.0.10", "10.128.0.20", "10.128.0.30"]
vault_server_names       = ["vault-1", "vault-2", "vault-3"]
