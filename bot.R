# ============================================================
# Bot do Telegram - Validador de CPF
# ============================================================
# Dependência: pacote telegram.bot
# Instale com: install.packages("telegram.bot")
# ============================================================

library(telegram.bot)
source("cpf_validator.R")

# ── Handlers ────────────────────────────────────────────────

## /start  – mensagem de boas-vindas
start <- function(bot, update) {
  bot$sendMessage(
    chat_id = update$message$chat_id,
    text    = paste0(
      "\U0001F916 *Olá! Sou o ValidaCPF Bot.*\n\n",
      "Envie um CPF (com ou sem formatação) e eu digo se ele é *válido* ou *inválido*.\n\n",
      "Exemplos aceitos:\n",
      "`123.456.789-09`\n",
      "`12345678909`\n\n",
      "Digite /ajuda para mais informações."
    ),
    parse_mode = "Markdown"
  )
}

## /ajuda  – instruções detalhadas
ajuda <- function(bot, update) {
  bot$sendMessage(
    chat_id = update$message$chat_id,
    text    = paste0(
      "\U0001F4CB *Como usar o ValidaCPF Bot*\n\n",
      "*Comandos disponíveis:*\n",
      "/start  – Mensagem de boas-vindas\n",
      "/ajuda  – Esta mensagem de ajuda\n\n",
      "*Validação de CPF:*\n",
      "Basta enviar o número do CPF no chat. O bot aceita:\n",
      "• Com formatação: `123.456.789-09`\n",
      "• Sem formatação: `12345678909`\n\n",
      "*Critérios de validação:*\n",
      "• 11 dígitos numéricos\n",
      "• Não pode ser uma sequência repetida (ex: 111.111.111-11)\n",
      "• Dígitos verificadores calculados pelo algoritmo oficial da Receita Federal"
    ),
    parse_mode = "Markdown"
  )
}

## Mensagens de texto – interpreta como CPF
mensagem_texto <- function(bot, update) {
  texto <- update$message$text
  chat_id <- update$message$chat_id

  resultado <- validar_cpf(texto)

  if (resultado$valido) {
    resposta <- paste0(
      "\U00002705 *CPF Válido!*\n\n",
      "\U0001F4CB CPF informado: `", resultado$cpf_formatado, "`"
    )
  } else {
    resposta <- paste0(
      "\U0000274C *CPF Inválido!*\n\n",
      "\U0001F4CB CPF informado: `", resultado$cpf_formatado, "`\n",
      "\U00002139\U0000FE0F Motivo: ", resultado$motivo
    )
  }

  bot$sendMessage(
    chat_id    = chat_id,
    text       = resposta,
    parse_mode = "Markdown"
  )
}

# ── Montar e iniciar o bot ───────────────────────────────────

# Lê o token do arquivo .env (ou variável de ambiente)
token <- Sys.getenv("TELEGRAM_BOT_TOKEN")

if (nchar(token) == 0) {
  # Tenta ler de arquivo .env local
  if (file.exists(".env")) {
    env_lines <- readLines(".env")
    token_line <- grep("^TELEGRAM_BOT_TOKEN=", env_lines, value = TRUE)
    if (length(token_line) > 0) {
      token <- sub("^TELEGRAM_BOT_TOKEN=", "", token_line[1])
    }
  }
}

if (nchar(token) == 0) {
  stop(
    "Token do bot nao encontrado!\n",
    "Defina a variavel de ambiente TELEGRAM_BOT_TOKEN ou crie um arquivo .env com:\n",
    "TELEGRAM_BOT_TOKEN=seu_token_aqui"
  )
}

bot <- Bot(token = token)
updater <- Updater(bot = bot)

# Registrar handlers
updater <- updater +
  CommandHandler("start", start) +
  CommandHandler("ajuda", ajuda) +
  MessageHandler(mensagem_texto, MessageFilters$text)

cat("Bot iniciado! Pressione Ctrl+C para encerrar.\n")
updater$start_polling()
