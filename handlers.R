
for (pkg in c("plumber", "jsonlite")) {
  if (!requireNamespace(pkg, quietly = TRUE))
    install.packages(pkg, repos = "https://cran.r-project.org")
}

library(plumber)


validar_cpf <- function(cpf) {
  cpf_limpo <- gsub("[^0-9]", "", cpf)
  if (nchar(cpf_limpo) != 11)
    return(list(valido = FALSE, motivo = "CPF deve ter 11 dígitos numéricos."))
  if (length(unique(strsplit(cpf_limpo, "")[[1]])) == 1)
    return(list(valido = FALSE, motivo = "Todos os dígitos são iguais."))
  d <- as.integer(strsplit(cpf_limpo, "")[[1]])
  r1 <- (sum(d[1:9] * 10:2) * 10) %% 11
  dv1 <- ifelse(r1 >= 10, 0, r1)
  if (d[10] != dv1)
    return(list(valido = FALSE, motivo = "Primeiro dígito verificador incorreto."))
  r2 <- (sum(d[1:10] * 11:2) * 10) %% 11
  dv2 <- ifelse(r2 >= 10, 0, r2)
  if (d[11] != dv2)
    return(list(valido = FALSE, motivo = "Segundo dígito verificador incorreto."))
  return(list(valido = TRUE, motivo = "CPF válido."))
}

formatar_cpf <- function(cpf) {
  c <- gsub("[^0-9]", "", cpf)
  if (nchar(c) == 11)
    return(paste0(substr(c,1,3),".",substr(c,4,6),".",substr(c,7,9),"-",substr(c,10,11)))
  return(cpf)
}

function() {
  list(status = "ok", servico = "Bot Validador de CPF", versao = "1.0.0")
}

function(cpf = "") {
  if (cpf == "") return(list(erro = "Informe o CPF na URL: /validar/12345678909"))
  res <- validar_cpf(cpf)
  list(cpf_informado = cpf, cpf_formatado = formatar_cpf(cpf),
       valido = res$valido, motivo = res$motivo,
       timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"))
}

function(req) {
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) NULL)
  if (is.null(body) || is.null(body$cpf))
    return(list(erro = "Envie JSON: {\"cpf\": \"123.456.789-09\"}"))
  cpf <- as.character(body$cpf)
  res <- validar_cpf(cpf)
  list(cpf_informado = cpf, cpf_formatado = formatar_cpf(cpf),
       valido = res$valido, motivo = res$motivo,
       timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"))
}

function(req) {
  body <- tryCatch(jsonlite::fromJSON(req$postBody), error = function(e) NULL)
  if (is.null(body) || is.null(body$cpfs))
    return(list(erro = "Envie JSON: {\"cpfs\": [\"12345678909\", \"...\"]}"))
  resultados <- lapply(body$cpfs, function(cpf) {
    res <- validar_cpf(as.character(cpf))
    list(cpf_informado = cpf, cpf_formatado = formatar_cpf(cpf),
         valido = res$valido, motivo = res$motivo)
  })
  list(total = length(resultados),
       validos = sum(sapply(resultados, function(r) r$valido)),
       invalidos = sum(!sapply(resultados, function(r) r$valido)),
       resultados = resultados,
       timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"))
}
