
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # cloudflare_ruleset.main will be updated in-place
  ~ resource "cloudflare_ruleset" "main" {
        id           = "1cd69b0985594b56b3014a3e3bb826c2"
      ~ last_updated = "2026-05-07T00:46:58Z" -> (known after apply)
        name         = "Geo Block"
      ~ rules        = [
          ~ {
              ~ id                = "109748a8f6074471b17138d8c1e2879b" -> (known after apply)
              ~ logging           = {
                  ~ enabled = true -> (known after apply)
                } -> (known after apply)
              ~ ref               = "109748a8f6074471b17138d8c1e2879b" -> (known after apply)
                # (5 unchanged attributes hidden)
            },
          ~ {
              ~ expression        = (sensitive value)
              ~ id                = "cd3fabe05c7a450cafd15353a74fc7c0" -> (known after apply)
              ~ logging           = {
                  ~ enabled = true -> (known after apply)
                } -> (known after apply)
              ~ ref               = "cd3fabe05c7a450cafd15353a74fc7c0" -> (known after apply)
                # (4 unchanged attributes hidden)
            },
          ~ {
              ~ id                = "4d284a46e7664b49aef51a10152ed75a" -> (known after apply)
              + logging           = (known after apply)
              ~ ref               = "4d284a46e7664b49aef51a10152ed75a" -> (known after apply)
                # (5 unchanged attributes hidden)
            },
          ~ {
              ~ id                = "b119654517f7446cb461f9620f08db07" -> (known after apply)
              + logging           = (known after apply)
              ~ ref               = "b119654517f7446cb461f9620f08db07" -> (known after apply)
                # (5 unchanged attributes hidden)
            },
        ]
      ~ version      = "8" -> (known after apply)
        # (4 unchanged attributes hidden)
    }

  # cloudflare_zone_dnssec.main_zone_dnssec will be updated in-place
  ~ resource "cloudflare_zone_dnssec" "main_zone_dnssec" {
      ~ algorithm           = "13" -> (known after apply)
      ~ digest              = "6B9EB7700A32D12FFFBCFF776124B366C0F89746F9D319981CEC540B37BEAFC1" -> (known after apply)
      ~ digest_algorithm    = "SHA256" -> (known after apply)
      ~ digest_type         = "2" -> (known after apply)
      + dnssec_multi_signer = false
      + dnssec_presigned    = false
      + dnssec_use_nsec3    = false
      ~ ds                  = "roccosmodernsite.net. 3600 IN DS 2371 13 2 6B9EB7700A32D12FFFBCFF776124B366C0F89746F9D319981CEC540B37BEAFC1" -> (known after apply)
      ~ flags               = 257 -> (known after apply)
        id                  = "f5ddaca671ac53ee0442c5ea08772dcf"
      ~ key_tag             = 2371 -> (known after apply)
      ~ key_type            = "ECDSAP256SHA256" -> (known after apply)
      ~ modified_on         = "2026-05-04T15:55:26Z" -> (known after apply)
      ~ public_key          = "mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+KkxLbxILfDLUT0rAK9iUzy1L53eKGQ==" -> (known after apply)
      ~ status              = "pending" -> "active"
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 2 to change, 0 to destroy.
