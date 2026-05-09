
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # google_monitoring_dashboard.miniflux_dashboard will be updated in-place
  ~ resource "google_monitoring_dashboard" "miniflux_dashboard" {
      ~ dashboard_json = jsonencode(
          ~ {
              - etag         = "b07394c8bc7fffcca603d66266f46445"
              ~ mosaicLayout = {
                  ~ tiles   = [
                      ~ {
                          ~ widget = {
                              ~ xyChart = {
                                  ~ dataSets = [
                                      ~ {
                                          - plotType        = "LINE"
                                          - targetAxis      = "Y1"
                                            # (1 unchanged attribute hidden)
                                        },
                                    ]
                                }
                                # (1 unchanged attribute hidden)
                            }
                          + xPos   = 0
                          + yPos   = 0
                            # (2 unchanged attributes hidden)
                        },
                      ~ {
                          ~ widget = {
                              ~ xyChart = {
                                  ~ dataSets = [
                                      ~ {
                                          - plotType        = "LINE"
                                          - targetAxis      = "Y1"
                                            # (1 unchanged attribute hidden)
                                        },
                                    ]
                                }
                                # (1 unchanged attribute hidden)
                            }
                          + yPos   = 0
                            # (3 unchanged attributes hidden)
                        },
                      ~ {
                          + xPos   = 0
                            # (4 unchanged attributes hidden)
                        },
                    ]
                    # (1 unchanged attribute hidden)
                }
              - name         = "projects/946657193590/dashboards/705f644f-6b35-41ad-98df-0163d778b56e"
                # (1 unchanged attribute hidden)
            }
        )
        id             = "projects/946657193590/dashboards/705f644f-6b35-41ad-98df-0163d778b56e"
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
