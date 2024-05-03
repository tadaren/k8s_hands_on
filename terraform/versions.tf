terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
  }
}
