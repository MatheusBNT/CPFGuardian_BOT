# 🤖 ValidaCPF Bot — Telegram + R

Bot do Telegram escrito em R que valida CPFs usando o algoritmo oficial da Receita Federal.

---

## 📁 Estrutura do projeto

```
telegram_cpf_bot/
├── bot.R               # Ponto de entrada — inicia o bot
├── cpf_validator.R     # Módulo de validação de CPF (puro R, sem dependências externas)
├── teste_validador.R   # Suite de testes do validador
├── .env.exemplo        # Modelo para o arquivo de configuração
└── README.md
```

---

## ⚙️ Pré-requisitos

- R ≥ 4.0
- Pacote `telegram.bot`

```r
install.packages("telegram.bot")
```

---

## 🚀 Como usar

### 1. Criar o bot no Telegram

1. Abra o Telegram e procure por **@BotFather**
2. Envie `/newbot` e siga as instruções
3. Copie o **token** fornecido ao final

### 2. Configurar o token

Crie um arquivo `.env` na raiz do projeto:

```
TELEGRAM_BOT_TOKEN=1234567890:ABCDefGhIJKlmNoPQRsTUVwxyZ
```

Ou exporte como variável de ambiente antes de iniciar o R:

```bash
export TELEGRAM_BOT_TOKEN="1234567890:ABCDefGhIJKlmNoPQRsTUVwxyZ"
```

### 3. Iniciar o bot

```r
source("bot.R")
```

Ou via terminal:

```bash
Rscript bot.R
```

---

## ✅ Executar os testes

```bash
Rscript teste_validador.R
```

Saída esperada: todos os 9 casos de teste passando.

---

## 💬 Comandos do bot

| Comando  | Descrição                      |
|----------|-------------------------------|
| `/start` | Mensagem de boas-vindas        |
| `/ajuda` | Instruções de uso              |
| (texto)  | Valida o CPF enviado           |

### Exemplos de uso no Telegram

```
Você:  529.982.247-25
Bot:   ✅ CPF Válido!
       📋 CPF informado: 529.982.247-25

Você:  123.456.789-00
Bot:   ❌ CPF Inválido!
       📋 CPF informado: 123.456.789-00
       ℹ️ Motivo: Dígitos verificadores inválidos
```

---

## 🔍 Algoritmo de validação

O validador aplica os critérios da Receita Federal:

1. **Comprimento**: exatamente 11 dígitos numéricos
2. **Sequências inválidas**: rejeita CPFs com todos os dígitos iguais (ex: `111.111.111-11`)
3. **1º dígito verificador**: soma ponderada dos 9 primeiros dígitos (pesos 10→2), resto da divisão por 11
4. **2º dígito verificador**: soma ponderada dos 10 primeiros dígitos (pesos 11→2), resto da divisão por 11

---

## 📦 Dependências

| Pacote        | Versão mínima | Uso                     |
|---------------|---------------|-------------------------|
| `telegram.bot`| 2.4.0         | Interface com a API do Telegram |

O módulo `cpf_validator.R` é puro R base — sem dependências externas.
