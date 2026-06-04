# ============================================================
#  telegram_api.R — Comunicação com a API HTTP do Telegram
# ============================================================

library(httr)

# Busca novas mensagens via long polling.
# Retorna lista de updates ou lista vazia em caso de erro.
get_updates <- function(offset = NULL) {
  params <- list(timeout = TIMEOUT_S, allowed_updates = '["message"]')
  if (!is.null(offset)) params$offset <- offset

  resp <- GET(
    url   = paste0(BASE_URL, "/getUpdates"),
    query = params,
    timeout(TIMEOUT_S + 5)
  )

  if (http_error(resp)) return(list())

  body <- content(resp, as = "parsed", simplifyVector = FALSE)
  if (!isTRUE(body$ok)) return(list())

  body$result
}

# Envia uma mensagem de texto para o chat_id informado.
send_message <- function(chat_id, text, parse_mode = "Markdown") {
  POST(
    url  = paste0(BASE_URL, "/sendMessage"),
    body = list(
      chat_id    = chat_id,
      text       = text,
      parse_mode = parse_mode
    ),
    encode = "json"
  )
}
