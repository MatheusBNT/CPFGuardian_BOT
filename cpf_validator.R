# ============================================================
# cpf_validator.R – Módulo de validação de CPF (Receita Federal)
# ============================================================

#' Remove tudo que não for dígito de uma string
#' @param cpf string com o CPF
#' @return string apenas com dígitos
limpar_cpf <- function(cpf) {
  gsub("[^0-9]", "", trimws(cpf))
}

#' Formata um CPF limpo no padrão 000.000.000-00
#' @param cpf_limpo string de 11 dígitos
#' @return string formatada
formatar_cpf <- function(cpf_limpo) {
  if (nchar(cpf_limpo) != 11) return(cpf_limpo)
  paste0(
    substr(cpf_limpo, 1, 3), ".",
    substr(cpf_limpo, 4, 6), ".",
    substr(cpf_limpo, 7, 9), "-",
    substr(cpf_limpo, 10, 11)
  )
}

#' Calcula um dígito verificador do CPF
#' @param digitos vetor numérico com os dígitos base
#' @param peso_inicial peso inicial para o cálculo (10 para 1º dígito, 11 para 2º)
#' @return dígito verificador calculado (0-9)
calcular_digito <- function(digitos, peso_inicial) {
  pesos <- seq(peso_inicial, 2)
  soma  <- sum(digitos * pesos)
  resto <- soma %% 11
  ifelse(resto < 2, 0L, 11L - resto)
}

#' Valida um CPF de acordo com o algoritmo da Receita Federal
#'
#' @param cpf string com o CPF (com ou sem formatação)
#' @return lista com campos:
#'   \itemize{
#'     \item \code{valido}         – logical TRUE/FALSE
#'     \item \code{cpf_formatado}  – CPF no padrão 000.000.000-00 (ou o input original se inválido)
#'     \item \code{motivo}         – descrição do erro (NA se válido)
#'   }
validar_cpf <- function(cpf) {
  cpf_original <- as.character(cpf)
  cpf_limpo    <- limpar_cpf(cpf_original)

  # ── 1. Comprimento ─────────────────────────────────────────
  if (nchar(cpf_limpo) != 11) {
    return(list(
      valido        = FALSE,
      cpf_formatado = cpf_original,
      motivo        = paste0("O CPF deve ter 11 dígitos (informado: ", nchar(cpf_limpo), ")")
    ))
  }

  # ── 2. Sequências inválidas (ex: 000...000, 111...111) ─────
  if (grepl("^(\\d)\\1{10}$", cpf_limpo)) {
    return(list(
      valido        = FALSE,
      cpf_formatado = formatar_cpf(cpf_limpo),
      motivo        = "CPF com todos os dígitos iguais não é válido"
    ))
  }

  # ── 3. Dígitos verificadores ───────────────────────────────
  digitos <- as.integer(strsplit(cpf_limpo, "")[[1]])

  d1_calculado <- calcular_digito(digitos[1:9],  peso_inicial = 10)
  d2_calculado <- calcular_digito(digitos[1:10], peso_inicial = 11)

  if (digitos[10] != d1_calculado || digitos[11] != d2_calculado) {
    return(list(
      valido        = FALSE,
      cpf_formatado = formatar_cpf(cpf_limpo),
      motivo        = "Dígitos verificadores inválidos"
    ))
  }

  # ── Válido ─────────────────────────────────────────────────
  list(
    valido        = TRUE,
    cpf_formatado = formatar_cpf(cpf_limpo),
    motivo        = NA_character_
  )
}
