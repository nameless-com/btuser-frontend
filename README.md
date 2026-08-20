# btuser-frontend

App iOS (SwiftUI) do **jogador**: encontra arenas, vê quadras e faz reservas.

## Setup

```bash
# clone bt-shared ao lado deste repo (../bt-shared)
brew install xcodegen
xcodegen generate
open BTUser.xcodeproj
```

Backend local: `swift run App serve` em `bt-backend`. A URL vem de `BTUser/Config/Debug.xcconfig` (`API_BASE_URL`). Login de teste: `jogador@bt.dev` / `123456`.

Toda comunicação com a API passa pelo `APIClient` do pacote `bt-shared` — não crie chamadas HTTP aqui.

---

# BT200 — Plano inicial

## Arquitetura

```
┌──────────────────┐     ┌──────────────────┐
│  btuser-frontend │     │ btgestor-frontend│   SwiftUI / iOS 17
│  (jogador)       │     │ (gestor arena)   │
└────────┬─────────┘     └────────┬─────────┘
         │   import BTShared      │
         └───────────┬────────────┘
                     ▼
            ┌─────────────────┐
            │    bt-shared    │  DTOs + Endpoint + APIClient
            └────────┬────────┘
                     │ import BTShared (DTOs viram Content)
                     ▼
            ┌─────────────────┐      ┌──────────┐
            │   bt-backend    │─────▶│ Postgres │ (SQLite em dev)
            │   Vapor 4       │      └──────────┘
            └─────────────────┘
```

**Por que um pacote compartilhado:** os dois apps e o servidor compilam contra os mesmos tipos. Mudou um campo num DTO → o compilador aponta nos três projetos. Sem isso, o típico "o app do gestor ainda manda `price` mas o backend espera `pricePerHourCents`" só aparece em runtime.

**Mesmo endpoint, papéis diferentes:** o JWT carrega `role` (`player`/`manager`). `GET /bookings` e `GET /arenas` são as mesmas rotas nos dois apps; o backend filtra pelo papel. Cada app só aceita login do seu papel (`Session.requiredRole`).

## Repos

| repo | o que é | comando |
|---|---|---|
| `bt-shared` | Swift package (contrato) | `swift build` |
| `bt-backend` | API Vapor | `swift run App serve` |
| `btuser-frontend` | app jogador | `xcodegen generate && open BTUser.xcodeproj` |
| `btgestor-frontend` | app gestor | `xcodegen generate && open BTGestor.xcodeproj` |

Clonar os 4 **lado a lado** — as dependências em `bt-shared` usam `path: ../bt-shared`.

## Fases

### Fase 0 — Fundação ✅ (feito)
- [x] bt-shared com DTOs, `Endpoint`, `APIClient`, `TokenStore`
- [x] Backend: auth JWT, arenas, quadras, reservas com checagem de conflito, seed de dev
- [x] Apps: login, lista de arenas → quadras → reserva (jogador); painel + arenas (gestor)
- [x] Keychain para token, xcconfig por ambiente, Dockerfile + compose

### Fase 1 — Fazer rodar de ponta a ponta (próximo passo)
1. Instalar Xcode completo (`xcode-select -s /Applications/Xcode.app`) — hoje só há CLT, por isso os apps não foram compilados.
2. Subir os 4 repos no GitHub; trocar `path: ../bt-shared` por `url:` + `branch: main` (ou manter path e documentar o clone lado a lado).
3. Rodar backend + app jogador no simulador: login `jogador@bt.dev`, fazer uma reserva.
4. Rodar app gestor: a reserva deve aparecer no painel.
5. CI (GitHub Actions): `swift build && swift test` em bt-shared e bt-backend; `xcodebuild` nos apps.

### Fase 2 — MVP de produto
- Gestor: CRUD de quadras (`POST/PATCH /arenas/:id/courts`), horário de funcionamento, bloqueio de horários
- Jogador: disponibilidade por dia (`GET /courts/:id/availability?date=`), grade de horários em vez de DatePicker livre
- Refresh token / expiração; recuperação de senha
- Deploy do backend (Fly.io/Railway) com Postgres; `API_BASE_URL` de Release apontando pra lá

### Fase 3 — Diferenciação
- Pagamento (Pix via Stripe/Pagar.me) com `BookingStatus.pending` → `confirmed` por webhook
- Push notifications (APNs) — confirmação e lembrete
- Partidas/ranking entre jogadores, busca de parceiro de jogo
- Versão iPad/macOS do app gestor (Catalyst ou target macOS — SwiftUI já permite)

## Convenções
- Contrato da API muda **sempre** primeiro em `bt-shared`; nunca redefinir DTO nos apps/backend.
- Dinheiro em centavos (`Int`), datas em ISO-8601 UTC.
- Rotas versionadas em `/api/v1`.
- Erros do backend: `{ "error": true, "reason": "..." }` (padrão Vapor, já decodificado pelo `APIClient`).
