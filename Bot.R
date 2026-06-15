library(telegram.bot)

# Token do Telegram (configure a variável BOT_TOKEN)

bot <- Bot(token = Sys.getenv("BOT_TOKEN"))

validar_cpf <- function(cpf) {

cpf <- gsub("[^0-9]", "", cpf)

if (nchar(cpf) != 11)
return(FALSE)

if (length(unique(strsplit(cpf, "")[[1]])) == 1)
return(FALSE)

nums <- as.numeric(strsplit(cpf, "")[[1]])

soma1 <- sum(nums[1:9] * 10:2)
dig1 <- ifelse(soma1 %% 11 < 2, 0, 11 - soma1 %% 11)

soma2 <- sum(nums[1:10] * 11:2)
dig2 <- ifelse(soma2 %% 11 < 2, 0, 11 - soma2 %% 11)

nums[10] == dig1 && nums[11] == dig2
}

offset <- 0

cat("Bot CPF iniciado...\n")

repeat {

updates <- bot$getUpdates(offset = offset)

if (length(updates) > 0) {

```
for (update in updates) {

  if (is.null(update$message))
    next

  if (is.null(update$message$text))
    next

  texto <- trimws(update$message$text)

  resposta <- if (validar_cpf(texto)) {
    "✅ CPF válido"
  } else {
    "❌ CPF inválido"
  }

  bot$sendMessage(
    chat_id = update$message$chat$id,
    text = resposta
  )

  offset <- update$update_id + 1
}
```

}

Sys.sleep(2)
}

