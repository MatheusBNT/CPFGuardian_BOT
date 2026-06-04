# ============================================================
#  config.R — Configurações globais do bot
# ============================================================
#
#  O token é lido do arquivo .env (nunca escreva o token aqui).
#  Formato do .env:
#    TELEGRAM_TOKEN=123456:ABC-xyz...
# ============================================================
 
# Operador utilitário: retorna `b` quando `a` é NULL
`%||%` <- function(a, b) if (!is.null(a)) a else b
 
# Carrega variáveis do .env se o arquivo existir
env_file <- ".env"
if (file.exists(env_file)) {
  linhas <- readLines(env_file, warn = FALSE)
  linhas <- linhas[grepl("^[^#].+=", linhas)]   # ignora comentários e linhas vazias
  for (linha in linhas) {
    partes <- strsplit(linha, "=", fixed = TRUE)[[1]]
    chave  <- trimws(partes[1])
    valor  <- trimws(partes[2])
    do.call(Sys.setenv, setNames(list(valor), chave))
  }
}
 
TOKEN <- Sys.getenv("TELEGRAM_BOT_TOKEN")
if (nchar(TOKEN) == 0) stop("Token não encontrado. Defina TELEGRAM_BOT_TOKEN no arquivo .env")
 
BASE_URL  <- paste0("https://api.telegram.org/bot", TOKEN)
TIMEOUT_S <- 30   # segundos de long polling