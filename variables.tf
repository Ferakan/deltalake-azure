variable "region" {
  type = string
  default = "eastus"
}

variable "subscription_id" {
  type = string
  default = "from azure account"
  sensitive = true
}

variable "tenant_id" {
  type = string
  default = "from azure account"
  sensitive = true
}

variable "blob_prefix" {
  type    = list(string)
  default = ["bronze", "silver", "gold"]
}

variable reddit_client_id {
  type = string
  default = "from reddit app"
  sensitive = true
}

variable reddit_client_secret {
  type = string
  default = "from reddit app"
  sensitive = true
}