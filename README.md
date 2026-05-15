validar_cpf <- function(cpf){

  # tira pontos e traços
  cpf <- gsub("[^0-9]", "", cpf)

  # verifica se tem 11 numeros
  if(nchar(cpf) != 11){
    return(FALSE)
  }

  # separa os numeros
  numeros <- as.numeric(strsplit(cpf, "")[[1]])

  # primeiro digito
  soma1 <- 0

  for(i in 1:9){
    soma1 <- soma1 + (numeros[i] * (11 - i))
  }

  resto1 <- (soma1 * 10) %% 11

  if(resto1 == 10){
    resto1 <- 0
  }

  # verifica primeiro digito
  if(resto1 != numeros[10]){
    return(FALSE)
  }

  # segundo digito
  soma2 <- 0

  for(i in 1:10){
    soma2 <- soma2 + (numeros[i] * (12 - i))
  }

  resto2 <- (soma2 * 10) %% 11

  if(resto2 == 10){
    resto2 <- 0
  }

  # verifica segundo digito
  if(resto2 != numeros[11]){
    return(FALSE)
  }

  return(TRUE)
}
