# ============================================================
# teste_validador.R – Testa o módulo cpf_validator.R
# Execute com: Rscript teste_validador.R
# ============================================================

source("cpf_validator.R")

# ── Casos de teste ───────────────────────────────────────────
casos <- list(
  # CPF válidos
  list(cpf = "529.982.247-25", esperado = TRUE,  descricao = "CPF válido formatado"),
  list(cpf = "52998224725",    esperado = TRUE,  descricao = "CPF válido sem formatacao"),
  list(cpf = "111.444.777-35", esperado = TRUE,  descricao = "CPF válido formatado 2"),

  # CPF inválidos
  list(cpf = "000.000.000-00", esperado = FALSE, descricao = "Sequência de zeros"),
  list(cpf = "111.111.111-11", esperado = FALSE, descricao = "Sequência de uns"),
  list(cpf = "123.456.789-00", esperado = FALSE, descricao = "Dígitos verificadores errados"),
  list(cpf = "123.456.789",    esperado = FALSE, descricao = "CPF incompleto (9 dígitos)"),
  list(cpf = "abc.def.ghi-jk", esperado = FALSE, descricao = "Letras no lugar de dígitos"),
  list(cpf = "",               esperado = FALSE, descricao = "String vazia")
)

# ── Executor dos testes ──────────────────────────────────────
cat("=== Testes do Validador de CPF ===\n\n")

passou <- 0
falhou <- 0

for (caso in casos) {
  resultado <- validar_cpf(caso$cpf)
  ok <- resultado$valido == caso$esperado

  status <- if (ok) "\u2705 PASSOU" else "\u274C FALHOU"
  if (ok) passou <- passou + 1 else falhou <- falhou + 1

  cat(sprintf(
    "%s | %-40s | CPF: %-20s | Válido: %-5s | Motivo: %s\n",
    status,
    caso$descricao,
    caso$cpf,
    resultado$valido,
    ifelse(is.na(resultado$motivo), "-", resultado$motivo)
  ))
}

cat(sprintf(
  "\n=== Resultado: %d/%d testes passaram ===\n",
  passou, passou + falhou
))
