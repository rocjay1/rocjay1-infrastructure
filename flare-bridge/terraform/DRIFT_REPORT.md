
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # cloudflare_d1_database.main will be updated in-place
  ~ resource "cloudflare_d1_database" "main" {
      ~ created_at       = "2026-05-03T12:16:57Z" -> (known after apply)
      ~ file_size        = 24576 -> (known after apply)
        id               = "a15743c7-c6d3-4ad4-819f-572ac75ff9b8"
        name             = "flare-bridge-db"
      ~ num_tables       = 1 -> (known after apply)
      - read_replication = {
          - mode = "disabled" -> null
        } -> null
      ~ version          = "production" -> (known after apply)
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
