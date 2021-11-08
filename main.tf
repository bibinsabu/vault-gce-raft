

data "template_file" "default" {
  count    = length(var.vault_server_names)
  template = file("${path.module}/templates/userdata-vault-server.tpl")
  vars = {
    tpl_vault_project    = var.gcloud-project,
    tpl_vault_node_name  = "${var.vault_server_names[count.index]}",
    tpl_vault_path       = "/opt/${var.vault_server_names[count.index]}",
    tpl_vault_zip_file   = var.vault_zip_file,
    tpl_vault_tag        = var.network-tag,
    tpl_vault_key_ring   = var.key_ring,
    tpl_vault_crypto_key = var.crypto_key
  }
}

resource "google_service_account" "vault_kms_service_account" {
  account_id   = "vault-gcpkms"
  display_name = "Vault KMS for auto-unseal"
}

resource "google_project_iam_binding" "project" {
  project = "${var.gcloud-project}"
  role    = "roles/editor"
    members = [
      "serviceAccount:${google_service_account.vault_kms_service_account.email}"
    ]
  }

resource "google_compute_instance" "vault" {
  name                    = "vault-server-${var.vault_server_names[count.index]}"
  count                   = length(var.vault_server_names)
  machine_type            = "${var.machine_type}"
  zone                    = var.gcloud-zone[count.index]
  tags                    = ["${var.network-tag}"]
  metadata_startup_script = data.template_file.default[count.index].rendered

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "default"
    network_ip = var.vault_server_private_ips[count.index]

    access_config {
      # Ephemeral IP
    }
  }

  allow_stopping_for_update = true

  # Service account with Cloud KMS roles for the Compute Instance
  service_account {
    email  = google_service_account.vault_kms_service_account.email
    scopes = ["cloud-platform", "compute-rw", "userinfo-email", "storage-ro"]
  }
}

#Create a KMS key ring
resource "google_kms_key_ring" "key_ring" {
  project  = var.gcloud-project
  name     = var.key_ring
  location = var.keyring_location
}

#Create a crypto key for the key ring
resource "google_kms_crypto_key" "crypto_key" {
  name            = var.crypto_key
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "100000s"
}

# Add the service account to the Keyring
resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.key_ring.id
  # key_ring_id = "${var.gcloud-project}/${var.keyring_location}/${var.key_ring}"
  role = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.vault_kms_service_account.email}",
  ]
}

# Add the firewall rules to access vault UI
resource "google_compute_firewall" "ssh_firewall" {
  name          = "vault-firewall"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network-tag}"]
  allow {
    protocol = "tcp"
    ports    = ["22", "8200", "8201"]
  }
}