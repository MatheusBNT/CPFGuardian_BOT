# ============================================================
#  handlers.R — Lógica de resposta às mensagens recebidas
# ============================================================

# Processa uma mensagem recebida e envia a resposta adequada.
processar_mensagem <- function(msg) {
  chat_id <- msg$chat$id
  texto   <- trimws(msg$text %||% "")

  # ── Comandos de ajuda ───────────────────────────────────────
  if (texto %in% c("/start", "/ajuda", "/help")) {
    resposta <- paste0(
      "👋 *Bem-vindo ao Validador de CPF!*\n\n",
      "Envie um CPF (com ou sem formatação) e eu direi se é válido.\n\n",
      "*Exemplos:*\n",
      "`123.456.789-09`\n",
      "`12345678909`\n\n",
      "Comandos:\n",
      "/start ou /ajuda — exibe esta mensagem"
    )
    send_message(chat_id, resposta)
    return(invisible(NULL))
  }

  # ── Verifica se parece um CPF ───────────────────────────────
  tem_digitos <- grepl("[0-9]{8,}", gsub("[^0-9]", "", texto))
  if (!tem_digitos || nchar(texto) > 20) {
    send_message(
      chat_id,
      "⚠️ Não reconheci um CPF na sua mensagem.\nEnvie apenas o CPF, por exemplo: `123.456.789-09`"
    )
    return(invisible(NULL))
  }

  # ── Valida e responde ───────────────────────────────────────
  # validar_cpf() retorna: list(valido, cpf_formatado, motivo)
  resultado <- validar_cpf(texto)

  if (resultado$valido) {
    resposta <- paste0("✅ *CPF válido!*\n\n🔢 `", resultado$cpf_formatado, "`")
  } else {
    resposta <- paste0(
      "❌ *CPF inválido!*\n\n",
      "🔢 `", resultado$cpf_formatado, "`\n",
      "📌 Motivo: ", resultado$motivo
    )
  }

  send_message(chat_id, resposta)
}
