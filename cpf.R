#!/usr/bin/env Rscript
# ============================================================
#  INICIALIZADOR DO SERVIDOR
#  Execute: Rscript cpf_iniciar.R
# ============================================================

for (pkg in c("plumber", "httr2", "jsonlite")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Instalando:", pkg))
    install.packages(pkg, repos = "https://cran.r-project.org")
  }
}

library(plumber)

PORT <- 8080

cat("╔══════════════════════════════════════════════╗\n")
cat("║    🤖  Bot Validador de CPF — API REST       ║\n")
cat("╚══════════════════════════════════════════════╝\n\n")
cat(sprintf("🚀 Iniciando servidor na porta %d...\n\n", PORT))
cat("📡 Rotas disponíveis:\n")
cat(sprintf("   GET  http://localhost:%d/health\n", PORT))
cat(sprintf("   GET  http://localhost:%d/validar/<CPF>\n", PORT))
cat(sprintf("   POST http://localhost:%d/validar\n", PORT))
cat(sprintf("   POST http://localhost:%d/validar/lote\n", PORT))
cat("\n💡 Use Ctrl+C para encerrar o servidor.\n")
cat("──────────────────────────────────────────────\n\n")

pr <- plumb("cpf_api_server.R")
pr$run(host = "0.0.0.0", port = PORT, swagger = TRUE)
