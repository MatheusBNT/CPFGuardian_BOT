# 🤖 CPFGuardian BOT
 
Bot do Telegram escrito em R que valida CPFs em tempo real, seguindo o algoritmo oficial da Receita Federal. A comunicação com o Telegram é feita diretamente via API HTTP, sem uso de nenhuma biblioteca específica do Telegram.
 
---
 
## Funcionalidades
 
- Valida CPFs com ou sem formatação (`123.456.789-09` ou `12345678909`)
- Detecta sequências inválidas (`111.111.111-11`, `000.000.000-00`, etc.)
- Verifica os dois dígitos verificadores pelo método módulo 11
- Retorna o CPF formatado junto com o resultado
- Exibe o motivo exato quando o CPF é inválido
- Token protegido via variável de ambiente (arquivo `.env`)
---
 
## Pré-requisitos
 
- R ≥ 4.0
- Pacote `httr`
- Uma conta no Telegram e um bot criado via [@BotFather](https://t.me/BotFather)
---
 
## Instalação
 
**1. Clone ou baixe o projeto:**
 
```bash
git clone https://github.com/seu-usuario/CPFGuardian_BOT.git
cd CPFGuardian_BOT
```
 
**2. Instale a dependência:**
 
```r
install.packages("httr")
```
 
**3. Crie o bot no Telegram:**
 
- Abra o Telegram e converse com [@BotFather](https://t.me/BotFather)
- Digite `/newbot` e siga as instruções
- Copie o token gerado (formato: `123456789:ABC-xyz...`)
**4. Configure o token:**
 
Crie um arquivo `.env` na raiz do projeto com o conteúdo:
 
```
TELEGRAM_TOKEN=SEU_TOKEN_AQUI
```
 
> ⚠️ O arquivo `.env` já está no `.gitignore` e **nunca deve ser commitado**.
 
---
 
## Como executar
 
Entre na pasta do projeto e rode:
 
```bash
cd C:\Users\seu-usuario\CPFGuardian_BOT
Rscript main.R
```
 
Quando o bot iniciar, você verá no terminal:
 
```
🤖 Bot iniciado! Aguardando mensagens...
   Pressione Ctrl+C para encerrar.
```
 
A partir daí, qualquer mensagem enviada ao bot no Telegram será processada e respondida.
 
---
 
## Como usar o bot
 
| Você envia | Bot responde |
|---|---|
| `/start` ou `/ajuda` | Mensagem de boas-vindas com instruções |
| `123.456.789-09` | ✅ CPF válido |
| `12345678909` | ✅ CPF válido |
| `111.111.111-11` | ❌ CPF com todos os dígitos iguais não é válido |
| `123.456.789-00` | ❌ Dígitos verificadores inválidos |
| `1234` | ⚠️ CPF não reconhecido |
 
---
 
## Estrutura do projeto
 
```
CPFGuardian_BOT/
├── main.R           # Ponto de entrada — carrega os módulos e inicia o loop
├── config.R         # Lê o token do .env e define configurações globais
├── telegram_api.R   # Funções de comunicação com a API HTTP do Telegram
├── cpf.R            # Algoritmo de validação e formatação de CPF
├── handlers.R       # Lógica de resposta para cada tipo de mensagem
├── .env             # Token do bot (não versionado)
└── .gitignore       # Garante que o .env não vá para o repositório
```
 
### Responsabilidade de cada arquivo
 
**`config.R`** — lê o `.env`, define `TOKEN`, `BASE_URL`, `TIMEOUT_S` e o operador `%||%`. Nenhum segredo fica hardcoded no código.
 
**`telegram_api.R`** — encapsula as duas chamadas à API do Telegram:
- `get_updates(offset)` — busca novas mensagens via long polling
- `send_message(chat_id, text)` — envia uma resposta ao usuário
**`cpf.R`** — módulo de negócio isolado e testável:
- `limpar_cpf()` — remove máscara
- `formatar_cpf()` — aplica máscara `000.000.000-00`
- `calcular_digito()` — módulo 11
- `validar_cpf()` — retorna `list(valido, cpf_formatado, motivo)`
**`handlers.R`** — decide o que responder com base no texto recebido.
 
**`main.R`** — carrega todos os módulos com `source()` e executa o loop de polling.
 
---
 
## Segurança do token
 
O token **nunca** fica escrito no código-fonte. O fluxo é:
 
```
.env  →  Sys.setenv()  →  Sys.getenv("TELEGRAM_BOT_TOKEN")  →  TOKEN
```
 
O `.gitignore` bloqueia o `.env` para que ele não seja enviado ao repositório acidentalmente. Se o token for comprometido, revogue-o diretamente no [@BotFather](https://t.me/BotFather) com o comando `/revoke`.
 
---
 
## Algoritmo de validação (Receita Federal)
 
1. Remove a formatação e verifica se há exatamente 11 dígitos
2. Rejeita sequências com todos os dígitos iguais
3. Calcula o **1º dígito verificador**: multiplica os 9 primeiros dígitos pelos pesos 10 a 2, soma os produtos, calcula o resto por 11; se o resto for < 2, o dígito é 0, caso contrário é 11 − resto
4. Repete o processo para o **2º dígito verificador** usando os 10 primeiros dígitos e pesos 11 a 2
5. Compara os dígitos calculados com os informados
---
 
## Licença
 
MIT
 