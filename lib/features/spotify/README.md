# Spotify / perfil musical (Backend B)

As telas consomem `SpotifyRepository`: `load({forceRefresh: false})`, `connect()`
(serve também para reconectar) e `disconnect()`. Cada ação devolve
`SpotifyProfileState`: `status` (`connected`, `notConnected`, `expired`), `profile`,
`isCached`, `failure` com mensagem em português e `isEmpty`. O provider de apresentação
marca loading enquanto aguarda essas ações. Nenhum token entra neste contrato.

`MusicProfile` usa `userId` do LOVIC, `artists`, `tracks`, `genres` e `syncedAt` UTC.
Itens usam `id`, `name`, `imageUrl` opcional. Artistas incluem `genres` e músicas
`artistIds`. Os nomes JSON iguais são um contrato novo aditivo: Arthur precisa mapear
esses campos para sua persistência; não se assume tabela/RPC existente. Gêneros são
normalizados para minúsculas, espaços simples, ordenados e sem duplicação.

`CachedSpotifyRepository` recebe usuário autenticado, `SpotifyTokenProvider`,
`SpotifyMusicDataSource` e `MusicProfileStore` para cache. A porta opcional
`persistedProfiles` é implementada pelo Arthur para leitura/gravação autorizada de
perfil salvo. O cache em memória é real, separado por usuário, com TTL técnico de
24 horas injetável. Falha de API preserva o último perfil válido e `syncedAt`; perfil
vazio vindo de uma resposta válida é aceito. Falha ao salvar no backend mantém o
perfil recém sincronizado no cache, mas retorna aviso de domínio para permitir nova
tentativa. A leitura de perfil de outra pessoa utiliza `MusicProfileStore.read(id)`
do Arthur, nunca as credenciais da pessoa selecionada.

A implementação OAuth utiliza Authorization Code + PKCE S256, `state` aleatório
validado, callback exato e somente o escopo `user-top-read`. É uma implementação
cliente segura e substituível por `SpotifyOAuthDataSource` caso o grupo escolha um
broker de tokens. O app guarda credenciais apenas em `FlutterSecureStorage`, com
chave por usuário LOVIC. `SpotifyTokenProvider` é o único ponto de refresh, deduplica
requisições simultâneas e conserva refresh token se o Spotify não enviar um novo.
O Backend A deve chamar `disconnect()` no logout/remoção da conta antes de descartar
o escopo. Não adicionar logs/interceptors que imprimam cabeçalhos ou corpos OAuth.

Para conectar de verdade, configurar client ID **público** e redirect URI registrado
no Spotify Dashboard. A política atual exige HTTPS, exceto IP loopback explícito
para desenvolvimento. Usar App/Universal Links do domínio do grupo, configurar o
callback nativo do `flutter_web_auth_2` e o endpoint `auth.html` no Web conforme o
plugin. Nenhum domínio ou credencial fictícia é usado no fluxo real. O transporte
de navegador é uma porta para permitir uma adaptação de plataforma; desktop precisa
validar suporte a callback loopback no plugin antes de habilitar conexão.

Os tops são lidos de `/v1/me/top/artists` e `/v1/me/top/tracks`, com limite 50 e
`medium_term`. As duas leituras precisam concluir antes de substituir o cache. 401/403
pedem reconexão; 429 respeita `Retry-After` (fallback técnico 60 s); demais erros
geram mensagens de domínio e permitem cache. Não há Apple Music ou mock de produção.

Dependências: `dio`, `crypto`, `flutter_secure_storage`, `flutter_web_auth_2` 4.x.

Referências oficiais consultadas:
- https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow
- https://developer.spotify.com/documentation/web-api/tutorials/refreshing-tokens
- https://developer.spotify.com/documentation/web-api/concepts/redirect_uri
- https://developer.spotify.com/documentation/web-api/reference/get-users-top-artists-and-tracks
- https://pub.dev/packages/flutter_web_auth_2
