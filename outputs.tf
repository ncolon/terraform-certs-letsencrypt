output "router_cert" {
  value = local.router_cert
}

output "router_key" {
  sensitive = true
  value     = local.router_key
}

output "router_ca" {
  value = local.router_issuer
}
