terraform {
  cloud {
    organization = "hqr-blesses"

    workspaces {
      name = "hqr-auto-scaling-terraform"
    }
  }
}
