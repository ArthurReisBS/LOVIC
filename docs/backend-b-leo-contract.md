# Contrato Backend B — Léo

Este documento é a entrega de integração da seção 3 do alinhamento
Frontend × Backend. Ele descreve apenas a parte do Léo. Adaptadores de
Supabase, sessão, RLS, dados cadastrais, persistência de curtida/match e criação
de conversa continuam com Arthur.

As telas consomem repositórios/providers. Nenhuma tela deve chamar Spotify,
Geolocator ou Supabase diretamente.

## Composição Riverpod

O app já inicia dentro de `ProviderScope`. Os pontos de composição ficam em
`lib/app/backend_b_providers.dart`. No bootstrap autenticado, Arthur/Isabelle
devem sobrescrever os providers com os adaptadores concretos da sessão:

- `spotifyRepositoryProvider`;
- `discoveryRepositoryProvider`;
- `ownLocationRepositoryProvider`;
- `likeRepositoryProvider`.

Enquanto um adaptador obrigatório não estiver configurado, o provider falha de
forma explícita. Não há fallback silencioso para mock.

## Meu Perfil e Spotify

Entrada da UI: `SpotifyRepository`.

```dart
Future<SpotifyProfileState> load({bool forceRefresh = false});
Future<SpotifyProfileState> connect();
Future<SpotifyProfileState> disconnect();
```

`SpotifyProfileState.status` é `connected`, `notConnected` ou `expired`. O
estado também informa `profile`, `isCached` e falha segura para a UI. O
`MusicProfile` tem `userId`, `artists`, `tracks`, `genres` e `syncedAt`.
Artista e música possuem `id`, `name` e `imageUrl` opcional.

O fluxo concreto usa OAuth Authorization Code com PKCE, somente `clientId`
público e token em armazenamento seguro por usuário. Nunca existe client secret
no app. A URI HTTPS deve ser cadastrada no painel Spotify e configurada como
Universal Link/App Link do aplicativo antes de ligar o botão. O cache em memória
é do Léo; Arthur implementa `MusicProfileStore` durável no Supabase.

## Home/Descoberta e perfil de outra pessoa

Entrada da UI: `DiscoveryRepository`.

```dart
Future<DiscoveryResult> discover({required MusicProfile viewer});
Future<DiscoveryProfileResult> getProfile({
  required MusicProfile viewer,
  required String userId,
});
```

Arthur implementa `DiscoveryDataSource.fetchNearby` e `fetchProfile`. Cada
candidato entregue ao Léo contém dados base, `MusicProfile` salvo e somente
`distanceKm`; coordenadas de terceiros não fazem parte do tipo.

O resultado para o card tem `id`, `name`, `age`, `bio`, `photoUrl`, `genres`,
`affinity`, `distanceKm` e `rankingScore`. O perfil completo acrescenta
`artists`, `tracks` e `musicProfile.syncedAt`. `DiscoveryResult.isEmpty` representa uma lista
vazia real; `error` representa falha tipada.

A afinidade usa Jaccard com pesos fixos 50% artistas, 30% gêneros e 20% músicas.
O ranking usa 80% afinidade e 20% proximidade, com fallback configurável de
30 km. As regras ficam fora das telas e possuem testes unitários.

## Localização

Entrada da UI, depois de Isabelle obter consentimento:

```dart
Future<LocationUpdateResult> updateOwnLocation({
  required bool permissionGranted,
});
```

Chamar ao entrar/voltar à descoberta ou logo após permitir. A leitura é apenas
da posição própria, em foreground, e o fallback de intervalo mínimo é 15
minutos. Arthur implementa `OwnLocationWriter`; a porta não aceita `userId`, pois
o dono deve vir da sessão autenticada. O retorno para UI nunca contém
coordenadas.

Estados: `updated`, `throttled`, `permissionDenied`, `serviceDisabled`,
`readFailed`, `networkError` e `cancelled` (sessão encerrada durante a leitura).

## Curtir/Match

Entrada da UI:

```dart
Future<LikeResult> like({
  required String targetUserId,
  required double affinity,
});
```

O JSON compartilhado é:

```json
{
  "deuMatch": true,
  "conversationId": "uuid-ou-id-acordado",
  "reason": "mutual_like"
}
```

Sem match, `conversationId` é `null` e `reason` é `no_match`. Os códigos
propostos são `mutual_like`, `high_affinity` e `no_match`; Arthur e Isabelle
devem confirmá-los antes de ligar o contrato compartilhado. Arthur implementa
a operação atômica que persiste, deduplica e cria/retorna a conversa. O limiar
de afinidade alta é obrigatoriamente injetado da configuração de produto;
nenhum valor foi inventado no cliente.

Falhas usam `LikeFailureCode`: `sessionExpired`, `invalidRequest`,
`invalidResponse` ou `unavailable`. A UI não precisa interpretar `StateError`,
`DioException`, mensagens do banco ou payloads técnicos.

## Pendências explícitas de integração

- Arthur: implementar as quatro portas Supabase, validar score no ambiente
  confiável e fornecer configuração/limiar de produto.
- Arthur/DevOps: cadastrar o client ID e a URI HTTPS no Spotify; configurar o
  App/Universal Link correspondente. Client secret não entra no app.
- Isabelle: trocar a tela de demonstração pelos providers, renderizar
  loading/vazio/erro e solicitar a permissão de localização.
- Grupo: confirmar os códigos de `reason` antes de mudar um contrato usado pelo
  frontend.
