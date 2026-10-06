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

#### Decisão do grupo: focar só no CP5
O grupo decidiu entregar **apenas o CP5** e deixar o CP6 para depois, porque não havia tempo de fazer os dois com qualidade. Nada do que foi construído para o CP6 foi descartado: a camada de Spotify, afinidade, descoberta, curtir/match e localização do Léo está no repositório, testada, e as telas foram feitas para trocar os dados de exemplo por dados reais sem serem refeitas.

#### Júlia — Product Owner e frontend
- Priorizou o escopo do CP5 e acompanhou as dependências entre o time.
- Telas: edição de perfil completa (foto do avatar, nome, bio, **gêneros musicais**, gênero, sexualidade, altura e galeria de até 6 fotos), visualizador de fotos em tela cheia, filtro do feed por gênero musical, "Esqueceu a senha" com código por email, olhinho de mostrar/esconder senha, campos de texto legíveis sobre o gradiente e setas de voltar.
- Decisão: botões que ainda não têm função mostram "Em breve!" em vez de ficarem mortos, e o contador do sino só conta o que existe.
- Decisão: redefinição de senha por **código de 6 dígitos** no email (não por link), porque o app roda no desktop, onde não há como abrir um link de volta no app.
- Decisão: sem `.env` o app abre em **modo demonstração**; com banco configurado o feed nunca cai silenciosamente nos perfis de exemplo.

#### Arthur — Banco de dados e integração
- Criou o projeto Supabase e o [`supabase/schema.sql`](supabase/schema.sql): tabelas `profiles` e `mensagens`, bucket de fotos e regras de acesso (RLS).
- Ligou cadastro, login e perfil ao banco ([`lib/services/auth_service.dart`](lib/services/auth_service.dart)) e implementou o chat com mensagens em tempo real.
- Decisão: **Supabase em vez de Firebase**, porque o PostgreSQL com RLS deixa as regras de acesso no próprio banco.
- Decisão: o perfil é criado por um **trigger** (`handle_new_user`) junto com a conta, sem permitir insert direto pelo app, e o username é validado antes do cadastro (`username_disponivel`).
- Decisão: **cadastro direto, sem email de confirmação**, porque o plano gratuito manda poucos emails por hora e travaria a demonstração.
<!-- confirmar com o Arthur: SQL do chat e das fotos, e se há outra decisão que ele queira registrar -->

#### Isabelle — Fluxo de telas
- Implementou o fluxo de telas do CP5: login, cadastro em etapas, Home, feed de perfis, perfil, conversas, chat, notificações e configurações, com a navegação entre elas.
- Decisão: seguir o design do Figma da equipe e reaproveitar componentes (botão com gradiente, campos de texto, chips de gênero, barra de navegação).
<!-- confirmar com a Isabelle: estados de carregando/vazio/erro e decisões de navegação que ela queira registrar -->

#### Léo — Dados de exemplo e Backend B
- Criou a camada de domínio e dados em [`lib/features/`](lib/features/): Spotify, afinidade, descoberta, curtir/match e localização, todos com testes.
- Decisão: **afinidade = 50% artistas + 30% gêneros + 20% músicas**, comparando por Jaccard (itens em comum ÷ itens distintos). Sem dados, o componente vale zero.
- Decisão: **ranking da descoberta = 80% afinidade + 20% proximidade**, com raio padrão de 30 km.
- Decisão: **Spotify com Authorization Code + PKCE**, só o escopo `user-top-read`, 50 itens de médio prazo, e tokens guardados em armazenamento seguro, nunca no banco nem no código.
- Decisão: a **localização** só é enviada com permissão confirmada, no máximo a cada 15 minutos, e as coordenadas de outras pessoas nunca chegam ao app (a distância vem pronta do banco).
- Decisão: o código de domínio fica isolado de Supabase por interfaces, para o Arthur ligar o banco sem reescrever as regras.
- Detalhes: [`lib/features/*/README.md`](lib/features/), [`docs/backend-b-leo-contract.md`](docs/backend-b-leo-contract.md) e [`docs/testing-backend-b.md`](docs/testing-backend-b.md).

#### Carol e Manoella — Marca e design
- Definiram a identidade visual: paleta, tipografia, logo e tabela de cores dos gêneros ([`design/`](design/) e [`docs/marca.md`](docs/marca.md)). Pitch e modelo de negócio em [`docs/pitch.md`](docs/pitch.md).
<!-- confirmar com a Carol e a Manoella: decisões de marca (nome, tom de voz, cores) que queiram destacar -->

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

## Decisões técnicas

| Tema | Decisão | Por quê |
| ---- | ------- | ------- |
| Escopo | Entregar só o CP5 | Sem tempo de fazer CP5 e CP6 com qualidade; o CP6 aproveita tudo |
| Backend | Supabase (Auth, Postgres, RLS, Realtime, Storage) | Regras de acesso no próprio banco e sem servidor próprio para manter |
| Sem servidor REST | O app fala direto com o Supabase | Menos peças para o prazo; a RLS protege os dados |
| Perfil | Criado por trigger na criação da conta | O app não consegue inserir perfil de outra pessoa |
| Cadastro | Direto, sem email de confirmação | Limite de emails do plano gratuito |
| Senha | Redefinição por **código de 6 dígitos** no email | O app roda no desktop, onde não dá para abrir um link de volta no app |
| Fotos | Bucket `fotos` público; cada pessoa escreve só na própria pasta; até 6 fotos | Simples para o protótipo; leitura aberta para o feed funcionar |
| Chat | Tabela `mensagens` com Realtime; só quem está na conversa lê; cada um envia em nome próprio | Mensagem aparece na hora do outro lado |
| Modo demonstração | Sem `.env` o app abre com perfis de exemplo | Plano B se a internet falhar |
| Sem fallback silencioso | Com banco configurado, falha mostra erro e lista vazia, nunca perfis inventados | A demonstração não engana ninguém |
| Botões sem função | Mostram "Em breve!" | Nenhum botão fica sem resposta |
| Gêneros | Escolhidos em Editar perfil; quem não escolheu recebe gêneros de exemplo fixos | O Spotify só entra no CP6 |
| Afinidade | Calculada no app (50/30/20) | Regra pura e testável; a validação no servidor fica para o CP6 |
| Distância | Calculada no banco, nunca no app | Não expor coordenadas de outras pessoas |
| Arquitetura | Telas → providers → repositórios (interfaces) → fontes de dados | Trocar dados de exemplo por reais sem refazer telas |

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

A arquitetura do CP5 é a base do CP6: o que está em `lib/features/` já tem regras e testes; falta ligar ao banco e às telas.

### O que fica para o CP6

| # | Item | Situação no CP5 | O que falta | Quem |
| - | ---- | --------------- | ----------- | ---- |
| 1 | **Spotify real** | Código pronto e testado (login PKCE, top artistas e músicas, cache) | Registrar o app no Spotify Dashboard (client ID e redirect URI HTTPS), configurar o link de retorno no app, guardar o perfil musical no banco e ligar os botões "Login/Criar com Spotify" | Arthur, Léo, Isabelle |
| 2 | **Afinidade real** | Cálculo pronto; telas mostram gêneros escolhidos ou de exemplo | Depende do item 1 para ter artistas e músicas de duas pessoas; mostrar o score no feed e no perfil | Léo, Isabelle |
| 3 | **Descoberta por distância e ranking** | Feed lista as pessoas cadastradas, sem ordenar por afinidade ou distância | Fonte de dados no banco que devolve candidatos com distância pronta; ligar o ranking 80/20 e o raio | Arthur, Isabelle |
| 4 | **Localização por GPS** | Código pronto; mapa é uma imagem e o botão avisa "Em breve" | Onde guardar a posição (tabela ou colunas com RLS), permissões no Android/iOS, pedir permissão na tela, mapa real | Arthur, Isabelle |
| 5 | **Curtir e match** | Regras prontas; não há botão de curtir nas telas e não há tabela de curtidas | Tabela de curtidas e função no banco que cria o match e a conversa de uma vez; botão nas telas; definir o limiar de "afinidade alta" | Arthur, Isabelle, Júlia (produto) |
| 6 | **Chat ligado ao match** | Qualquer pessoa pode mandar mensagem para qualquer perfil | Decidir se só quem deu match conversa e ligar a conversa ao match | Júlia (produto), Arthur |
| 7 | **Notificações reais** | Um item de exemplo e contador | Tabela de notificações (curtida, match, mensagem) e leitura em tempo real | Arthur, Isabelle |
| 8 | **Login com Google** | Botão avisa "Em breve" | Configurar o provedor no Supabase e no Google | Arthur |
| 9 | **Email de confirmação** | Desligado no protótipo | Ligar a confirmação com um serviço de email próprio (SMTP), que também melhora o "Esqueceu a senha" | Arthur |
| 10 | **Busca por lugares, câmera e menus** | Avisam "Em breve" | Definir se entram no escopo | Júlia (produto) |

### Segurança e privacidade a revisar
- **Score de afinidade calculado no app** pode ser adulterado: validar ou recalcular no servidor antes de usar para dar match.
- **Fotos em bucket público:** qualquer pessoa com o link vê a foto. Avaliar links temporários.
- **Todos os perfis são legíveis por qualquer pessoa logada.** Quando houver distância e match, restringir o que cada pessoa vê.
- **Spotify:** o segredo do cliente nunca entra no app, e os tokens ficam só no armazenamento seguro do aparelho.

### Decisões em aberto
1. Qual é o limiar de "afinidade alta" que gera match automático?
2. Qual é o raio padrão da descoberta (o código usa 30 km como fallback)?
3. Chat liberado para todos ou só para quem deu match?
4. Quais códigos de motivo o match devolve (`mutual_like`, `high_affinity`, `no_match`)? Confirmar entre Arthur e Isabelle antes de ligar as telas.
5. Qual domínio e link de retorno serão registrados no Spotify?
