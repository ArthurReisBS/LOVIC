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

-- ---------------------------------------------------------------------------
-- Edição de perfil: gêneros musicais, informações pessoais e fotos.
-- ---------------------------------------------------------------------------
alter table public.profiles add column if not exists generos      text[] not null default '{}';
alter table public.profiles add column if not exists genero       text;
alter table public.profiles add column if not exists sexualidade  text;
alter table public.profiles add column if not exists altura_cm    int;
alter table public.profiles add column if not exists fotos        text[] not null default '{}';

-- Bucket público "fotos": cada usuário só escreve dentro da pasta com o
-- próprio id (<uid>/arquivo.jpg); qualquer um pode ver.
insert into storage.buckets (id, name, public)
values ('fotos', 'fotos', true)
on conflict (id) do nothing;

drop policy if exists "fotos visiveis" on storage.objects;
create policy "fotos visiveis"
  on storage.objects for select
  using (bucket_id = 'fotos');

drop policy if exists "usuario envia as proprias fotos" on storage.objects;
create policy "usuario envia as proprias fotos"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'fotos' and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "usuario apaga as proprias fotos" on storage.objects;
create policy "usuario apaga as proprias fotos"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'fotos' and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ---------------------------------------------------------------------------
-- Chat: mensagens entre duas pessoas.
-- ---------------------------------------------------------------------------
create table if not exists public.mensagens (
  id              bigint generated always as identity primary key,
  remetente_id    uuid not null references public.profiles (id) on delete cascade,
  destinatario_id uuid not null references public.profiles (id) on delete cascade,
  texto           text not null check (length(trim(texto)) between 1 and 2000),
  criado_em       timestamptz not null default now(),
  -- Mesma chave para os dois lados da conversa ("menor:maior"), usada no
  -- filtro do app e do tempo real.
  conversa        text generated always as (
    least(remetente_id::text, destinatario_id::text) || ':' ||
    greatest(remetente_id::text, destinatario_id::text)
  ) stored,
  check (remetente_id <> destinatario_id)
);

create index if not exists mensagens_conversa_idx
  on public.mensagens (conversa, criado_em);

alter table public.mensagens enable row level security;

-- Só quem está na conversa lê as mensagens dela.
drop policy if exists "participantes leem a conversa" on public.mensagens;
create policy "participantes leem a conversa"
  on public.mensagens for select
  to authenticated
  using (auth.uid() in (remetente_id, destinatario_id));

-- Cada um só envia mensagem em nome próprio.
drop policy if exists "usuario envia as proprias mensagens" on public.mensagens;
create policy "usuario envia as proprias mensagens"
  on public.mensagens for insert
  to authenticated
  with check (auth.uid() = remetente_id);

-- Tempo real: a mensagem nova aparece na tela de quem está do outro lado.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public' and tablename = 'mensagens'
  ) then
    alter publication supabase_realtime add table public.mensagens;
  end if;
end;
$$;
