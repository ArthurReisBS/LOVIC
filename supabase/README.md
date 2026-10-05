# Supabase — cadastro, login e perfil (CP05)

## Montar o banco (uma vez, quem cria o projeto)

1. Em [supabase.com](https://supabase.com), crie o projeto **LOVIC**.
2. **SQL Editor** → cole todo o [`schema.sql`](schema.sql) → **Run**.
3. **Authentication → Sign In / Providers → Email**: desligue **Confirm email**.
   O protótipo cadastra direto, sem código por email (o plano gratuito manda poucos emails por hora).
4. **Project Settings → API Keys**: copie a **URL** e a **publishable key** para o grupo.

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
| `public.profiles` | nome, sobrenome, data de nascimento, username, bio, foto — criado automaticamente no cadastro |

Regras (RLS): quem está logado vê os perfis; cada um só edita o próprio.

## Como testar

1. **Criar uma conta** → email → nome → username → senha → cai na Home.
2. No Supabase, **Table Editor → profiles**: a linha nova aparece com os dados do cadastro.
3. Ícone de perfil na barra de baixo → nome e `@username` vindos do banco.
4. Feche e abra o app: entra direto (sessão salva).
5. Login com senha errada → "Email ou senha incorretos."
