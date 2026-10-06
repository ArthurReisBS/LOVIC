# LOVIC

> Criando conexões a partir da arte musical

**LOVIC** é um aplicativo de relacionamentos que usa o **gosto musical** como principal critério de afinidade. Em vez de partir da foto, o app analisa os artistas e gêneros de cada usuário e sugere perfis.

Dois pilares sustentam a proposta:

- **Integração com streaming** (Spotify), para levantar o perfil musical sem formulário
- **Geolocalização (GPS)**, para que as recomendações sejam de pessoas por perto

**Status: Checkpoint 5 — protótipo funcional.** Telas navegáveis, com banco de dados real (Supabase) para conta, perfil, fotos e chat, e dados de exemplo no que depende de integrações externas (Spotify e GPS, previstos para o CP6).

---

## Integrantes e papéis

| Integrante | RM | Papel no projeto |
| ---------- | -- | ---------------- |
| **Arthur** | `RM562181` | Banco de dados (Supabase): cadastro, login, perfil e chat reais; ambiente de teste |
| **Isabelle** | `RM566464` | Fluxo de telas, navegação e estados de carregando/vazio/erro; ambiente de teste |
| **Carol** | `RM564651` | Marca e design: paleta, fontes, logo e cores dos gêneros |
| **Léo** | `RM563663` | Modelos e dados de exemplo; serviços de Spotify, afinidade, descoberta e localização (Backend B) |
| **Manoella** | `RM564469` | Marca e design: paleta, fontes, logo e cores dos gêneros; pitch |
| **Júlia** | `RM565010` | **Product Owner** e frontend: telas, edição de perfil, fotos, filtro por gênero, redefinição de senha; README e roteiro da demonstração |

### O que cada um fez e as decisões tomadas

#### Júlia — Product Owner e frontend
- Priorizou o escopo do CP5 e acompanhou as dependências entre o time.
- Telas: edição de perfil completa (foto do avatar, nome, bio, **gêneros musicais**, gênero, sexualidade, altura e galeria de até 6 fotos), visualizador de fotos em tela cheia, filtro do feed por gênero musical, "Esqueceu a senha" com código por email, olhinho de mostrar/esconder senha, campos de texto legíveis sobre o gradiente e setas de voltar.
- Decisão: botões que ainda não têm função mostram "Em breve!" em vez de ficarem mortos, e o contador do sino só conta o que existe.
- Decisão: redefinição de senha por **código de 6 dígitos** no email (não por link), porque o app roda no desktop, onde não há como abrir um link de volta no app.
- Decisão: sem `.env` o app abre em **modo demonstração**; com banco configurado o feed nunca cai silenciosamente nos perfis de exemplo.

#### Arthur — Banco de dados e integração
<!-- Preencher: o que fez e decisões (ex.: Supabase em vez de Firebase, trigger de criação de perfil, RLS, cadastro direto sem confirmação de email). -->
- Criou o projeto Supabase e o [`supabase/schema.sql`](supabase/schema.sql): tabelas `profiles` e `mensagens`, bucket de fotos e regras de acesso (RLS).
- Ligou cadastro, login e perfil ao banco ([`lib/services/auth_service.dart`](lib/services/auth_service.dart)).

#### Isabelle — Fluxo de telas
<!-- Preencher: o que fez e decisões (navegação, estados de carregando/vazio/erro, Meu Perfil). -->
- Navegação completa entre as telas e ligação das telas aos dados.

#### Léo — Dados de exemplo e Backend B
<!-- Preencher: o que fez e decisões. -->
- Camada de domínio e dados em [`lib/features/`](lib/features/): Spotify (PKCE e cache), afinidade musical, descoberta, curtir/match e localização, todos com testes. A fórmula de afinidade está em [`lib/features/affinity/README.md`](lib/features/affinity/README.md); o contrato em [`docs/backend-b-leo-contract.md`](docs/backend-b-leo-contract.md) e os testes em [`docs/testing-backend-b.md`](docs/testing-backend-b.md).

#### Carol e Manoella — Marca e design
<!-- Preencher: o que fizeram e decisões. -->
- Identidade visual: paleta, tipografia, logo e tabela de cores dos gêneros (ver [`design/`](design/) e [`docs/marca.md`](docs/marca.md)). Pitch e modelo de negócio em [`docs/pitch.md`](docs/pitch.md).

---

## Telas

| Feed | Home | Perfil |
|----------|----------|----------|
| ![feed](https://raw.githubusercontent.com/arthurreisbs/lovic/main/assets/images/Feed.png) | ![home](https://raw.githubusercontent.com/arthurreisbs/lovic/main/assets/images/TelaHome.png) | ![perfil](https://raw.githubusercontent.com/arthurreisbs/lovic/main/assets/images/TelaPerfil.png) |

### Fluxo principal

```
Login ──► Home ──► Encontre um par (feed) ──► Ver perfil ──► Mensagem (chat)
  │         │            ▲  filtro por gênero
  │         ├──► Notificações
  │         └──► Explore gêneros musicais ─┘
  └──► Criar conta (email → dados → username → senha)

Barra de baixo: Meu perfil · Feed · Home · Chats · Configurações
Meu perfil ──► Editar perfil          Configurações ──► Sair
Login ──► Esqueceu a senha? ──► código por email ──► nova senha
```

---

## O que funciona no CP5

### Com banco de dados real (Supabase)

| Funcionalidade | Detalhe |
| -------------- | ------- |
| Cadastro e login | Email e senha; a sessão fica salva e o app abre direto |
| Esqueceu a senha | Código de 6 dígitos por email e senha nova |
| Sair da conta | Configurações → Sair |
| Meu perfil | Foto, nome, @username, bio, gêneros, informações pessoais e fotos |
| Editar perfil | Foto do avatar, nome, bio, gêneros, gênero, sexualidade, altura e até 6 fotos (Supabase Storage) |
| Feed de perfis | Mostra as outras pessoas cadastradas, com idade calculada |
| Ver perfil | Foto, gêneros, "Sobre mim", informações e fotos; toque nas fotos para ampliar |
| Filtro por gênero | Na Home, tocar num gênero abre o feed só com quem curte aquele gênero; botão **Tirar filtro** |
| Chat | Mensagens salvas em `public.mensagens`, recebidas em tempo real; a aba **Chats** lista as conversas |

### Dados de exemplo (ficam para o CP6)

| Funcionalidade | Situação |
| -------------- | -------- |
| Gêneros de quem ainda não escolheu | Gêneros de exemplo fixos por usuário |
| Notificações | Dados de exemplo (1 item) |
| Mapa e localização | Imagem de exemplo; botão de localização avisa "Em breve" |
| Login com Google / Spotify | Avisa "Em breve" |
| Perfis de exemplo | Só aparecem em **modo demonstração** (sem `.env`) |

Estados tratados: carregando, lista vazia ("Ainda não há outras pessoas por aqui"), erro com "Tentar de novo" e feed filtrado sem resultados.

---

## Tecnologia

- **Flutter** (Dart) — Windows desktop, Chrome e Android
- **Supabase** — autenticação, PostgreSQL com RLS, Realtime e Storage
- **Riverpod e Dio** — estado e requisições (Backend B)
- **image_picker** — escolha de fotos da galeria

---

## Como rodar (do zero)

### 1. Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ≥ 3.9). Confira com `flutter doctor`.
- **Windows desktop:** Visual Studio ou Build Tools com a carga **"Desenvolvimento para desktop com C++"** e o componente individual **"C++ ATL para as ferramentas de build mais recentes (x86 e x64)"**. Sem o ATL o build falha com `atlstr.h: No such file or directory`.
- Modo desenvolvedor do Windows ligado (necessário para os plugins).

### 2. Banco de dados (uma vez, quem cria o projeto)

1. Em [supabase.com](https://supabase.com), crie o projeto **LOVIC**.
2. **SQL Editor** → cole todo o [`supabase/schema.sql`](supabase/schema.sql) → **Run**. Pode rodar de novo sem problema.
3. **Authentication → Sign In / Providers → Email**: desligue **Confirm email** (o protótipo cadastra direto).
4. **Authentication → Email Templates → Reset Password**: troque o corpo por `Seu código de redefinição: {{ .Token }}`.
5. **Project Settings → API Keys**: copie a **URL** e a **publishable key**.

Detalhes e roteiro de testes em [`supabase/README.md`](supabase/README.md).

### 3. Variáveis de ambiente e execução

```bash
cp .env.example .env      # preencha SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY
flutter pub get
flutter run --dart-define-from-file=.env
```

Sem o `.env` o app abre em **modo demonstração**: navega por todas as telas com perfis de exemplo, mas nada é salvo.

### 4. Testes

```bash
flutter analyze
flutter test
```

---

## Roteiro da demonstração

Antes: ter duas contas criadas (ex.: uma no app Windows e outra no Chrome) e o `schema.sql` já rodado.

1. **Criar conta** → email → nome e data de nascimento → username → senha (com o olhinho) → cai na Home.
2. **Meu perfil** (ícone de pessoa) → **Editar perfil** → trocar a foto, escolher gêneros musicais, preencher as informações e adicionar fotos → **Salvar**.
3. Entrar com a **segunda conta** → **Encontre um par**: a primeira aparece no feed.
4. **Ver perfil** → tocar numa foto para ampliar → deslizar entre as fotos.
5. Voltar à **Home** → tocar num gênero em "Explore gêneros musicais" → feed filtrado → **Tirar filtro**.
6. Botão de mensagem → enviar uma mensagem → ela aparece na hora na outra conta → aba **Chats** lista a conversa.
7. **Esqueceu a senha** (na tela de login) → código por email → senha nova → entrar de novo.
8. **Configurações** → **Sair**.

Plano B se a internet falhar: abrir o app **sem o `.env`** (modo demonstração) e percorrer as telas com os perfis de exemplo.

---

## Decisões técnicas (desde o CP4)

- **Supabase em vez de Firebase:** PostgreSQL com RLS deixa as regras de acesso no próprio banco (cada um só edita o próprio perfil e só lê as próprias conversas; fotos só na pasta do dono).
- **Perfil criado por trigger:** `handle_new_user` cria a linha em `profiles` junto com a conta, sem permitir insert direto pelo cliente.
- **Cadastro direto, sem email de confirmação:** o plano gratuito do Supabase manda poucos emails por hora, o que travaria a demonstração.
- **Modo demonstração sem banco:** garante que o app abra e navegue mesmo sem `.env` ou internet.
- **Sem fallback silencioso:** com banco configurado, falhas mostram erro e lista vazia, nunca perfis inventados.
- **Backend B isolado em `lib/features/`:** camadas `domain` e `data` com testes, para ligar às telas no CP6 sem reescrevê-las.
- **Botões sem função mostram "Em breve!"** em vez de ficarem sem resposta.

---

## Estrutura do repositório

```
.
├── docs/          # problema, público-alvo, MVP, marca, pitch, contratos e testes
├── design/        # logo, paleta de cores e tipografia
├── assets/images  # prints e imagens do app
├── lib/
│   ├── screens/   # telas (auth e home)
│   ├── widgets/   # componentes reutilizáveis
│   ├── services/  # AuthService e ChatService (Supabase)
│   ├── models/    # perfil e mapeamento do banco
│   ├── features/  # Backend B: spotify, afinidade, descoberta, matches, localização
│   └── core/      # tema, navegação e configuração
├── supabase/      # schema.sql e instruções do banco
└── test/
```

### Documentação

| Documento | Conteúdo |
| --------- | -------- |
| [`docs/problema-publico-mvp.md`](docs/problema-publico-mvp.md) | Problema, público-alvo e MVP |
| [`docs/marca.md`](docs/marca.md) | Naming rationale e tom de voz |
| [`docs/pitch.md`](docs/pitch.md) | Modelo de negócio e diferencial competitivo |
| [`supabase/README.md`](supabase/README.md) | Banco de dados e como testar |
| [`docs/backend-b-leo-contract.md`](docs/backend-b-leo-contract.md) | Contrato do Backend B |
| [`docs/testing-backend-b.md`](docs/testing-backend-b.md) | Como testar o Backend B |

---

## O MVP

- Cadastro e login
- Integração com Spotify — leitura dos artistas e gêneros mais ouvidos
- Cálculo de afinidade musical entre perfis
- Geração de matches: manual e automática quando a afinidade for alta
- Uso do GPS para exibir pessoas próximas

---

## Próximos passos (CP6)

A arquitetura do CP5 é a base do CP6: os dados de exemplo são trocados por dados reais sem refazer as telas.

- Spotify real e afinidade com as músicas de verdade
- Localização por GPS e distância real
- Match automático por afinidade
- Notificações reais
