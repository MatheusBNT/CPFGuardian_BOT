## ---------------------------------------------------------
## Bot validador de CPF — R + httr2 + Telegram Bot API
## ---------------------------------------------------------

library(httr2)

# --- Configuração ---------------------------------------------------

token <- Sys.getenv("TELEGRAM_BOT_TOKEN")

if (token == "") {
  stop("Variável TELEGRAM_BOT_TOKEN não definida. Configure-a antes de rodar o bot.")
}

base_url <- paste0("https://api.telegram.org/bot", token)

# --- Função de validação de CPF --------------------------------------

validar_cpf <- function(cpf) {
  cpf <- gsub("[^0-9]", "", cpf)

  # precisa ter exatamente 11 dígitos
  if (nchar(cpf) != 11) return(FALSE)

  digitos <- as.integer(strsplit(cpf, "")[[1]])

  # rejeita sequências de dígitos repetidos (ex: 00000000000, 11111111111)
  if (length(unique(digitos)) == 1) return(FALSE)

  calcular_digito <- function(nums, pesos) {
    soma <- sum(nums * pesos)
    resto <- soma %% 11
    if (resto < 2) 0L else as.integer(11 - resto)
  }

  d1 <- calcular_digito(digitos[1:9], 10:2)
  d2 <- calcular_digito(digitos[1:10], 11:2)

  d1 == digitos[10] && d2 == digitos[11]
}

# --- Funções de comunicação com o Telegram ---------------------------

enviar_mensagem <- function(chat_id, texto) {
  request(paste0(base_url, "/sendMessage")) |>
    req_body_json(list(chat_id = chat_id, text = texto)) |>
    req_perform()
}

obter_atualizacoes <- function(offset = NULL) {
  req <- request(paste0(base_url, "/getUpdates")) |>
    req_url_query(timeout = 30, offset = offset)

  resp <- req_perform(req)
  resp_body_json(resp)
}

formatar_cpf <- function(cpf) {
  cpf <- gsub("[^0-9]", "", cpf)
  sprintf("%s.%s.%s-%s",
          substr(cpf, 1, 3), substr(cpf, 4, 6),
          substr(cpf, 7, 9), substr(cpf, 10, 11))
}

# --- Loop principal do bot --------------------------------------------

offset <- NULL
message("Bot iniciado. Aguardando mensagens no Telegram...")

while (TRUE) {
  atualizacoes <- tryCatch(
    obter_atualizacoes(offset),
    error = function(e) {
      message("Erro ao buscar atualizações: ", conditionMessage(e))
      NULL
    }
  )

  if (!is.null(atualizacoes) && length(atualizacoes$result) > 0) {
    for (update in atualizacoes$result) {
      offset <- update$update_id + 1

      texto <- update$message$text
      chat_id <- update$message$chat$id

      if (is.null(texto) || is.null(chat_id)) next

      if (texto == "/start") {
        resposta <- "Olá! Me envie um número de CPF (com ou sem pontuação) e eu digo se ele é válido."
      } else if (grepl("[0-9]", texto)) {
        if (validar_cpf(texto)) {
          resposta <- paste0("✅ CPF válido: ", formatar_cpf(texto))
        } else {
          resposta <- paste0("❌ CPF inválido: ", texto)
        }
      } else {
        resposta <- "Envie um número de CPF para eu validar."
      }

      tryCatch(
        enviar_mensagem(chat_id, resposta),
        error = function(e) message("Erro ao enviar mensagem: ", conditionMessage(e))
      )
    }
  }

  Sys.sleep(1)
}
