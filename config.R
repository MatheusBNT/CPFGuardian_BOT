#!/usr/bin/env Rscript
# ============================================================
#  CLIENTE HTTP/2 — usa httr2 para consumir a API
#  Execute em outro terminal: Rscript cpf_cliente_httr2.R
# ============================================================

for (pkg in c("httr2", "jsonlite")) {
  if (!requireNamespace(pkg, quietly = TRUE))
    install.packages(pkg, repos = "https://cran.r-project.org")
}

library(httr2)
library(jsonlite)

BASE_URL <- "http://localhost:8080"

print_resultado <- function(r, cpf_label = NULL) {
  label <- if (!is.null(cpf_label)) cpf_label else r$cpf_formatado
  if (isTRUE(r$valido)) {
    cat(sprintf("  ✅  %-20s  VÁLIDO\n", label))
  } else {
    cat(sprintf("  ❌  %-20s  INVÁLIDO — %s\n", label, r$motivo))
  }
}

fazer_request <- function(req) {
  tryCatch(
    req_perform(req),
    error = function(e) {
      cat("❌ Erro de conexão. O servidor está rodando?\n")
      cat("   Execute: Rscript cpf_iniciar.R\n\n")
      quit(status = 1)
    }
  )
}


cat("\n╔══════════════════════════════════════════════╗\n")
cat("║   🤖  Cliente httr2 — Validador de CPF      ║\n")
cat("╚══════════════════════════════════════════════╝\n\n")

cat("🔎 [1] Health Check\n")
resp_health <- fazer_request(
  request(BASE_URL) |>
    req_url_path("/health") |>
    req_headers(Accept = "application/json") |>
    req_method("GET")
)
h <- resp_body_json(resp_health)
cat(sprintf("   Status: %s | Serviço: %s | v%s\n\n", h$status, h$servico, h$versao))

cat("🔎 [2] GET /validar/<cpf>  — validação individual\n")
cpfs_teste_get <- c("529.982.247-25", "111.111.111-11", "000.000.000-00", "12345678901")

for (cpf in cpfs_teste_get) {
  cpf_url <- gsub("[^0-9]", "", cpf)   # remove pontos/traço para URL
  resp <- fazer_request(
    request(BASE_URL) |>
      req_url_path(paste0("/validar/", cpf_url)) |>
      req_headers(Accept = "application/json") |>
      req_method("GET")
  )
  r <- resp_body_json(resp)
  print_resultado(r, cpf)
}
cat("\n")


cat("🔎 [3] POST /validar  — body JSON\n")
cpfs_post <- c("529.982.247-25", "999.999.999-99", "987.654.321-00")

for (cpf in cpfs_post) {
  resp <- fazer_request(
    request(BASE_URL) |>
      req_url_path("/validar") |>
      req_headers(
        "Content-Type" = "application/json",
        Accept         = "application/json"
      ) |>
      req_body_json(list(cpf = cpf)) |>
      req_method("POST")
  )
  r <- resp_body_json(resp)
  print_resultado(r, cpf)
}
cat("\n")


cat("🔎 [4] POST /validar/lote  — múltiplos CPFs\n")
lote <- list(cpfs = list(
  "529.982.247-25",
  "111.111.111-11",
  "123.456.789-09",
  "987.654.321-00",
  "000.000.000-00"
))

resp_lote <- fazer_request(
  request(BASE_URL) |>
    req_url_path("/validar/lote") |>
    req_headers(
      "Content-Type" = "application/json",
      Accept         = "application/json"
    ) |>
    req_body_json(lote) |>
    req_method("POST")
)
rl <- resp_body_json(resp_lote)
cat(sprintf("   Total: %d | ✅ Válidos: %d | ❌ Inválidos: %d\n",
            rl$total, rl$validos, rl$invalidos))
for (r in rl$resultados) print_resultado(r)
cat("\n")


cat("──────────────────────────────────────────────────\n")
cat("💬 Modo interativo — Digite CPFs para validar\n")
cat("   (Digite 'sair' para encerrar)\n")
cat("──────────────────────────────────────────────────\n\n")

repeat {
  entrada <- readline(prompt = "CPF > ")
  entrada <- trimws(entrada)
  if (entrada == "") next
  if (tolower(entrada) %in% c("sair", "exit", "q")) {
    cat("\n👋 Até mais!\n\n")
    break
  }

  cpf_url <- gsub("[^0-9]", "", entrada)
  resp <- tryCatch(
    req_perform(
      request(BASE_URL) |>
        req_url_path(paste0("/validar/", cpf_url)) |>
        req_headers(Accept = "application/json")
    ),
    error = function(e) NULL
  )

  if (is.null(resp)) {
    cat("❌ Erro de conexão.\n\n")
  } else {
    r <- resp_body_json(resp)
    print_resultado(r, entrada)
    cat("\n")
  }
}
