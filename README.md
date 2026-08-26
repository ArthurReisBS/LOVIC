# LOVIC

> Criando conexões a partir da arte musical

**LOVIC** é um aplicativo de relacionamentos que usa o **gosto musical** como principal critério de afinidade. Em vez de partir da foto, o app analisa os artistas e gêneros mais ouvidos de cada usuário e sugere perfis.

Dois pilares sustentam a proposta:

- **Integração com streaming** (Spotify / Apple Music), para levantar o perfil musical automaticamente, sem formulário
- **Geolocalização (GPS)**, para que as recomendações sejam de pessoas por perto e o encontro real seja viável

---

## Integrantes e papéis

| Integrante | RM | Responsabilidade neste CheckPoint |
| ---------- | -- | --------------------------------- |
| **Arthur** | `RM562181` | Repositório, README e estrutura de pastas do projeto |
| **Isabelle** | `RM566464` | Documentação inicial: problema, público-alvo e definição do MVP |
| **Carol** | `RM564651` | Marca: nome, *naming rationale* e tom de voz |
| **Léo** | `RM563663` | Identidade visual: logo, paleta de cores e tipografia |
| **Manoella** | `RM564469` | Pitch: modelo de negócio e diferencial competitivo |
| **Júlia** | `RM565010` | Projeto Flutter inicial e consolidação da entrega |

---

## Estrutura do repositório

```
.
├── docs/          # documentação escrita: problema, público-alvo, MVP e marca
├── design/        # logo, paleta de cores e tipografia
├── lib/           # código-fonte do app Flutter
└── README.md
```

### Documentação

| Documento | Conteúdo | Responsável |
| --------- | -------- | ----------- |
| [`docs/problema-publico-mvp.md`](docs/problema-publico-mvp.md) | Problema que o app resolve, público-alvo e funcionalidades do MVP | Isabelle |
| [`docs/marca.md`](docs/marca.md) | *Naming rationale* e tom de voz da marca | Carol |
| [`docs/pitch.md`](docs/pitch.md) | Modelo de negócio e diferencial competitivo | Manoella |
| [`design/`](design/) | Logo, paleta de cores (hex) e tipografia | Léo |

---

## O MVP

Funcionalidades mínimas para o app fazer sentido:

- Cadastro e login
- Integração com Spotify / Apple Music — leitura dos artistas e gêneros mais ouvidos
- Cálculo de afinidade musical entre perfis
- Geração de matches: manual e automático quando a afinidade for alta
- Uso do GPS para exibir pessoas próximas

> O detalhamento do público-alvo e do MVP está em [`docs/problema-publico-mvp.md`](docs/problema-publico-mvp.md).

---

## Tecnologia

- **Flutter** (Dart) — aplicação multiplataforma
- APIs de streaming musical para o perfil de gosto
- Serviços de geolocalização do dispositivo

### Rodando o projeto

```bash
flutter pub get
flutter run
```

Requer o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.

---