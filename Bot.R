  library(httr)
library(jsonlite)

TOKEN <- Sys.getenv("BOT_TOKEN")
BASE_URL <- paste0("https://api.telegram.org/bot", TOKEN)

validar_cpf <- function(cpf) {

  cpf <- gsub("[^0-9]", "", cpf)

  if (nchar(cpf) != 11)
    return(FALSE)

  if (length(unique(strsplit(cpf, "")[[1]])) == 1)
    return(FALSE)

  nums <- as.numeric(strsplit(cpf, "")[[1]])

  soma1 <- sum(nums[1:9] * 10:2)
  dig1 <- 11 - (soma1 %% 11)
  if (dig1 >= 10) dig1 <- 0

  soma2 <- sum(nums[1:10] * 11:2)
  dig2 <- 11 - (soma2 %% 11)
  if (dig2 >= 10) dig2 <- 0

  nums[10] == dig1 && nums[11] == dig2
}

ultimo_update <- 0

while(TRUE) {

  resp <- GET(
    paste0(BASE_URL, "/getUpdates"),
    query = list(offset = ultimo_update + 1, timeout = 30)
  )

  dados <- fromJSON(content(resp, "text", encoding = "UTF-8"))

  if (dados$ok && length(dados$result) > 0) {

    for (i in seq_along(dados$result$update_id)) {

      update <- dados$result[i, ]

      ultimo_update <- update$update_id

      chat_id <- update$message.chat.id
      texto <- update$message.text

      if (!is.null(texto) && nzchar(texto)) {

        if (validar_cpf(texto)) {
          resposta <- "✅ CPF válido!"
        } else {
          resposta <- "❌ CPF inválido!"
        }

        POST(
          paste0(BASE_URL, "/sendMessage"),
          body = list(
            chat_id = chat_id,
            text = resposta
          ),
          encode = "form"
        )
      }
    }
  }

  Sys.sleep(1)
}
