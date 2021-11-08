variable "gcloud-project" {
  description = "Google project name"
}

variable "gcloud-region" {
  description = "Google project region"

}

variable "gcloud-zone" {
  type = list(string)
}

variable "vault_server_names" {
  description = "Names of the Vault nodes that will join the cluster"
  type        = list(string)
}

variable "vault_server_private_ips" {
  description = "The private ips of the Vault nodes that will join the cluster"
  type        = list(string)
}

variable "vault_zip_file" {
  description = "URL for Vault OSS binary"
}

variable "machine_type" {
  description = "Instance size"
}

variable "network-tag" {
  description = "Tag for instance"
}

variable "account_file_path" {
  description = "Path to GCP account file"
}

variable "key_ring" {
  description = "Cloud KMS key ring name to create"
}

variable "crypto_key" {
  description = "Crypto key name to create under the key ring"
}

variable "keyring_location" {
}
