# 🤖 Bot Validador de CPF — Telegram (Rust)

Bot simples feito com *Rust + Teloxide* que valida CPFs usando o algoritmo oficial da Receita Federal.

---

## 📋 Pré-requisitos

- [Rust](https://rustup.rs/) (stable)
- Token de bot do Telegram (via [@BotFather](https://t.me/botfather))

---

## 🚀 Como rodar

### 1. Clone / baixe o projeto

bash
git clone <repo> && cd cpf_bot


### 2. Crie o bot no Telegram

Fale com o [@BotFather](https://t.me/botfather) e use /newbot para obter seu token.

### 3. Configure o token

bash
# Linux / macOS
export TELOXIDE_TOKEN="SEU_TOKEN_AQUI"

# Windows (PowerShell)
$env:TELOXIDE_TOKEN="SEU_TOKEN_AQUI"


### 4. Compile e execute

bash
cargo run --release


### 5. Rode os testes

bash
cargo test


---

## 💬 Comandos do bot

| Comando | Descrição |
|---|---|
| /start | Mensagem de boas-vindas |
| /help | Lista os comandos |
| /cpf <número> | Valida um CPF |

Você também pode *enviar o CPF direto* (sem comando) que o bot tenta validar automaticamente.

### Exemplos


/cpf 529.982.247-25   → ✅ válido
/cpf 52998224725      → ✅ válido (sem formatação)
/cpf 123.456.789-00   → ❌ inválido
529.982.247-25        → ✅ funciona sem o /cpf também


---

## 🔍 Como funciona a validação

O algoritmo segue a regra da *Receita Federal*:

1. Remove caracteres não numéricos (. e -)
2. Verifica se tem 11 dígitos
3. Rejeita sequências repetidas (000.000.000-00, 111.111.111-11, etc.)
4. Calcula o *1º dígito verificador* com pesos 10→2 nos 9 primeiros dígitos
5. Calcula o *2º dígito verificador* com pesos 11→2 nos 10 primeiros dígitos
6. Compara com os dígitos informados

---

## 📁 Estrutura


cpf_bot/
├── Cargo.toml      # dependências
└── src/
    └── main.rs     # lógica de validação + handlers do bot + testes


---

## 🛠️ Dependências

| Crate | Uso |
|---|---|
| teloxide | Framework Telegram Bot API |
| tokio | Runtime assíncrono |
| log + pretty_env_logger | Logging |
