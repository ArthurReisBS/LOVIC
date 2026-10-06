# Supabase — cadastro, login e perfil (CP05)

## Montar o banco (uma vez, quem cria o projeto)

1. Em [supabase.com](https://supabase.com), crie o projeto **LOVIC**.
2. **SQL Editor** → cole todo o [`schema.sql`](schema.sql) → **Run**.
3. **Authentication → Sign In / Providers → Email**: desligue **Confirm email**.
   O protótipo cadastra direto, sem código por email (o plano gratuito manda poucos emails por hora).
4. **Project Settings → API Keys**: copie a **URL** e a **publishable key** para o grupo.
5. **Esqueceu a senha** (código por email): em **Authentication → Email Templates → Reset Password**, troque o link do corpo do email por `Seu código de redefinição: {{ .Token }}`. O app pede esse código de 6 dígitos e a senha nova, sem precisar abrir link (funciona no desktop).

## Rodar o app ligado ao banco (cada um)

```bash
cp .env.example .env      # preencha SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY
flutter pub get
flutter run --dart-define-from-file=.env
```

Sem o `--dart-define-from-file=.env` o app abre em **modo demonstração**: as telas navegam normalmente, mas nada é salvo.

## O que fica no banco

| Onde | O quê |
| ---- | ----- |
| `auth.users` | conta: email e senha (gerenciada pelo Supabase) |
| `public.profiles` | nome, sobrenome, data de nascimento, username, bio, foto — criado automaticamente no cadastro. **Nome, sobrenome e bio são editáveis** no app (o username não) |
| `public.mensagens` | mensagens do chat: quem mandou, pra quem, texto e horário |

Regras (RLS): quem está logado vê os perfis; cada um só edita o próprio. Mensagens só são lidas por quem está na conversa, e cada um só envia em nome próprio.

### O que continua de exemplo (não está no banco)

- **Gêneros musicais** e **cor/foto do perfil**: gerados de forma fixa a partir do `id` até a integração com o Spotify e o upload de fotos (CP06).
- **Notificações**: não existe tabela para isso.
- **Login com Google/Spotify**, busca por lugares, localização, câmera e menus de três pontinhos: avisam "Em breve" / "chega no CP06".

## Como testar

0. **Esqueceu a senha**: Login → *Esqueceu a senha?* → email → o código chega por email → digite o código e a senha nova → volta ao login → entre com a senha nova. O "olhinho" nos campos de senha mostra/esconde o texto.

1. **Criar uma conta** → email → nome → username → senha → cai na Home.
2. No Supabase, **Table Editor → profiles**: a linha nova aparece com os dados do cadastro.
3. Ícone de perfil na barra de baixo → nome e `@username` vindos do banco.
4. Feche e abra o app: entra direto (sessão salva).
5. Login com senha errada → "Email ou senha incorretos."
6. **Editar perfil**: Meu Perfil → *Editar perfil* (ou Configurações → *Perfil*) → mude nome e bio → *Salvar*. A tela mostra os dados novos e a linha em `profiles` muda.
7. **Ver outros perfis**: crie uma segunda conta (outro email) e entre com a primeira → *Encontre um par* (ou ícone do feed) → a segunda conta aparece no feed, com username e idade reais. *Ver perfil* abre o perfil dela.
8. **Sair da conta**: Configurações → *Sair* → confirmar → volta ao login. Feche e abra o app: continua no login.
9. **Chat**: com duas contas (ex.: uma no Chrome e outra numa aba anônima), abra o perfil da outra → botão de mensagem → envie. A mensagem aparece na hora do outro lado, fica em **Table Editor → mensagens** e continua lá ao sair e abrir o chat de novo. Na aba **Chats** a conversa aparece com a última mensagem e o horário, e tocar nela abre o chat.
