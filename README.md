# 🤖 Bot Validador de CPF em R — com httr2 (HTTP/2)

Arquitetura cliente/servidor REST:

- **Servidor** → `plumber` expõe a API REST na porta 8080
- **Cliente** → `httr2` faz requisições HTTP/2 para consumir a API

---

## ⚙️ Setup no GitHub Codespace

### 1. Instalar R

```bash
sudo apt-get update && sudo apt-get install -y r-base r-base-dev libssl-dev libcurl4-openssl-dev
```

### 2. Instalar pacotes R

```bash
Rscript -e "install.packages(c('plumber', 'httr2', 'jsonlite'), repos='https://cran.r-project.org')"
```

---

## ▶️ Como Rodar

### Terminal 1 — Subir o servidor

```bash
Rscript cpf_iniciar.R
```

### Terminal 2 — Rodar o cliente httr2

```bash
Rscript cpf_cliente_httr2.R
```

---

## 📡 Endpoints da API

| Método | Rota               | Descrição                        |
|--------|--------------------|----------------------------------|
| GET    | `/health`          | Status do serviço                |
| GET    | `/validar/<cpf>`   | Valida CPF pela URL              |
| POST   | `/validar`         | Valida CPF via JSON body         |
| POST   | `/validar/lote`    | Valida múltiplos CPFs de uma vez |
| GET    | `/__docs__/`       | Swagger UI (documentação)        |

---

## 🔁 Exemplos com curl

```bash
# Health
curl http://localhost:8080/health

# GET individual
curl http://localhost:8080/validar/52998224725

# POST individual
curl -X POST http://localhost:8080/validar \
  -H "Content-Type: application/json" \
  -d '{"cpf": "529.982.247-25"}'

# POST lote
curl -X POST http://localhost:8080/validar/lote \
  -H "Content-Type: application/json" \
  -d '{"cpfs": ["529.982.247-25", "111.111.111-11", "000.000.000-00"]}'
```

---

## 📁 Arquivos

```
cpf_validator/
├── cpf_api_server.R      # Definição das rotas (plumber)
├── cpf_iniciar.R         # Inicia o servidor HTTP
├── cpf_cliente_httr2.R   # Cliente httr2 + bot interativo
└── README.md
```
