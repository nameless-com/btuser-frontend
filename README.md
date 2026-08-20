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
