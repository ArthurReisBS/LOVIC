-- LOVIC · CP05 — banco do cadastro, login e perfil (Backend A).
-- Rodar inteiro no SQL Editor do Supabase. Pode rodar de novo sem quebrar.

-- Perfil público de cada usuário. A conta (email/senha) fica em auth.users,
-- gerenciada pelo Supabase; aqui ficam só os dados que o app mostra.
create table if not exists public.profiles (
  id              uuid primary key references auth.users (id) on delete cascade,
  nome            text not null,
  sobrenome       text,
  data_nascimento date,
  username        text not null unique,
  bio             text,
  foto_url        text,
  criado_em       timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Quem está logado vê os perfis (é um app de encontrar gente).
drop policy if exists "perfis visiveis para logados" on public.profiles;
create policy "perfis visiveis para logados"
  on public.profiles for select
  to authenticated
  using (true);

-- Cada um só edita o próprio perfil.
drop policy if exists "usuario edita o proprio perfil" on public.profiles;
create policy "usuario edita o proprio perfil"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Não existe policy de insert: o perfil nasce pelo trigger abaixo, junto com
-- a conta, a partir dos dados que o app manda no signUp.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, nome, sobrenome, data_nascimento, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nome', ''),
    nullif(new.raw_user_meta_data ->> 'sobrenome', ''),
    nullif(new.raw_user_meta_data ->> 'data_nascimento', '')::date,
    -- conta criada pelo painel do Supabase não manda username
    coalesce(
      nullif(new.raw_user_meta_data ->> 'username', ''),
      'user_' || left(new.id::text, 8)
    )
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- O cadastro pergunta antes de criar a conta, pra dar um erro claro em vez
-- de "Database error saving new user" quando o username já existe.
create or replace function public.username_disponivel(nome_usuario text)
returns boolean
language sql
security definer
set search_path = ''
as $$
  select not exists (
    select 1 from public.profiles where lower(username) = lower(nome_usuario)
  );
$$;

grant execute on function public.username_disponivel(text) to anon, authenticated;
