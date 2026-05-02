output "sources_kv_namespace_id" {
  value       = cloudflare_workers_kv_namespace.sources_kv.id
  description = "The ID of the KV namespace for feed sources."
}
