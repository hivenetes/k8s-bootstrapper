resource "digitalocean_spaces_bucket" "loki_spaces" {
  count  = var.enable_external_s3 ? 1 : 0
  name   = var.s3_bucket_name
  region = var.s3_bucket_region
  acl    = "private"
}
