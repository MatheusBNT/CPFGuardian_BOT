# ============================================================
#  main.R — Ponto de entrada do Bot Validador de CPF
#
#  Como executar:
#    Rscript main.R
#
#  Pré-requisitos:
#    install.packages("httr")
#    Defina o TOKEN em config.R antes de rodar.
# ============================================================

source("config.R")
source("telegram_api.R")
source("cpf.R")
source("handlers.R")

# ── Loop principal ────────────────────────────────────────────

cat("🤖 Bot iniciado! Aguardando mensagens...\n")
cat("   Pressione Ctrl+C para encerrar.\n\n")

offset <- NULL

repeat {
  updates <- tryCatch(
    get_updates(offset),
    error = function(e) {
      cat("[ERRO ao buscar updates]", conditionMessage(e), "\n")
      Sys.sleep(5)
      list()
    }
  )

  for (upd in updates) {
    offset <- upd$update_id + 1   # avança offset para não reprocessar

    msg <- upd$message
    if (is.null(msg) || is.null(msg$text)) next

    cat(sprintf(
      "[%s] @%s (%s): %s\n",
      format(Sys.time(), "%H:%M:%S"),
      msg$from$username %||% "sem_user",
      msg$chat$id,
      msg$text
    ))

    tryCatch(
      processar_mensagem(msg),
      error = function(e) cat("[ERRO ao processar mensagem]", conditionMessage(e), "\n")
    )
  }
}
