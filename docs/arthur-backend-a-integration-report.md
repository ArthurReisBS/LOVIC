# Relatório para Arthur — integração Backend A × Backend B

## Resumo executivo

A parte do Léo está implementada e testada como regras e contratos Dart. Ela
não cria tabelas, RLS, autenticação, RPCs ou conversas, porque esses itens
continuam no Backend A.

Para transformar os contratos em fluxo real, Arthur precisa implementar quatro
portas e fornecer uma persistência de perfil musical:

| Prioridade | Porta | Responsabilidade do Arthur |
|---|---|---|
| 1 | `MusicProfileStore` | Ler/gravar o perfil musical autorizado |
| 2 | `OwnLocationWriter` | Gravar somente a posição do usuário autenticado |
| 3 | `DiscoveryDataSource` | Devolver candidatos elegíveis e distância segura em km |
| 4 | `BackendALikeDataSource` | Persistir curtida/match e criar/retornar conversa atomicamente |

Depois, os objetos concretos devem substituir os providers declarados em
`lib/app/backend_b_providers.dart`.

## 1. Persistência de perfil musical

Implementar:

```dart
abstract interface class MusicProfileStore {
  Future<MusicProfile?> read(String userId);
  Future<void> write(MusicProfile profile);
}
```

Campos que precisam sobreviver no banco:

- `userId` do LOVIC, não o ID do Spotify;
- artistas: `id`, `name`, `imageUrl`, `genres`;
- músicas: `id`, `name`, `imageUrl`, `artistIds`;
- gêneros normalizados;
- `syncedAt` em UTC.

Recomendação de banco: uma linha por usuário, com `user_id` único e os
arrays musicais em `jsonb`, ou tabelas relacionais equivalentes se já existirem.
O adaptador deve converter o schema real para `MusicProfile`; não é necessário
renomear tabelas existentes para seguir os nomes Dart.

Regras de segurança:

- escrita somente para `auth.uid() = user_id`;
- leitura do próprio perfil e dos candidatos somente conforme a política de
  descoberta;
- nunca persistir access token ou refresh token na tabela de perfil;
- tokens locais ficam em `flutter_secure_storage`.

## 2. Escrita da localização própria

Implementar:

```dart
abstract interface class OwnLocationWriter {
  Future<void> saveOwnPosition(OwnPosition position);
}
```

O método não recebe `userId` propositalmente. A função/RPC deve obter o dono
por `auth.uid()` e aceitar apenas latitude, longitude e `capturedAt`.

Cuidados obrigatórios:

- validar latitude `-90..90` e longitude `-180..180` também no banco;
- rejeitar sessão ausente/expirada;
- vincular o writer à sessão que o criou;
- ao logout, descartar `LocationRepository` chamando `dispose()`;
- RLS impede leitura/escrita arbitrária de coordenadas;
- coordenadas de terceiros nunca retornam ao app.

Sugestão de contrato RPC, adaptável ao schema existente:

```text
update_own_location(latitude, longitude, captured_at) -> void
```

## 3. Descoberta segura

Implementar:

```dart
abstract interface class DiscoveryDataSource {
  Future<List<DiscoveryCandidate>> fetchNearby({required double radiusKm});
  Future<DiscoveryCandidate?> fetchProfile(String userId);
}
```

Cada candidato deve ser convertido para:

```text
id
name
age
bio
photoUrl (opcional)
distanceKm
musicProfile
```

O RPC pode receber o raio, mas deve obter o usuário e sua posição pela sessão.
O retorno não pode conter latitude ou longitude de candidatos. `distanceKm`
deve ser calculada e arredondada no ambiente confiável.

Responsabilidades do banco:

- excluir o próprio usuário;
- aplicar elegibilidade/bloqueios/RLS;
- limitar pelo raio configurado;
- juntar dados cadastrais e o último perfil musical salvo;
- devolver somente campos seguros.

Responsabilidades já feitas pelo Léo:

- afinidade 50/30/20;
- proximidade normalizada pelo raio;
- ranking final 80/20;
- remoção defensiva de IDs repetidos;
- resultado ordenado, vazio e erros tipados.

Erros do Supabase devem ser traduzidos para `DiscoveryDataException`:

| Situação | Código Dart |
|---|---|
| rede/timeout | `DiscoveryError.network` |
| JWT/sessão inválida | `DiscoveryError.sessionExpired` |
| usuário sem localização | `DiscoveryError.locationRequired` |
| perfil solicitado inexistente/inacessível | `DiscoveryError.notFound` |
| erro não mapeado | `DiscoveryError.unexpected` |

## 4. Curtir e criar match/conversa

Implementar `BackendALikeDataSource` ou usar o adaptador por callback já pronto:

```dart
BackendALikeOperationDataSource((request) async {
  final result = await supabase.rpc(
    'nome_real_da_funcao',
    params: {
      'target_user_id': request.targetUserId,
      'affinity': request.affinity,
    },
  );
  return Map<String, Object?>.from(result as Map);
});
```

O nome da RPC e dos parâmetros acima é apenas exemplo. Use o schema real do
Arthur e converta a resposta para o contrato fixo:

```json
{
  "deuMatch": true,
  "conversationId": "id-da-conversa",
  "reason": "mutual_like"
}
```

Sem match:

```json
{
  "deuMatch": false,
  "conversationId": null,
  "reason": "no_match"
}
```

Pontos que precisam ser atômicos no Backend A:

- obter ator por `auth.uid()`, nunca confiar em ID vindo da tela;
- validar/recalcular afinidade em ambiente confiável quando necessário;
- impedir autocurtida;
- persistir a curtida sem duplicar;
- verificar curtida mútua e regra de afinidade alta;
- criar no máximo uma conversa para a dupla;
- em nova chamada, devolver a mesma conversa existente.

Os motivos propostos são `mutual_like`, `high_affinity` e `no_match`. Confirmar
com Isabelle/Júlia antes de mudar nomes compartilhados. Falhas técnicas são
convertidas pelo repositório do Léo para `LikeFailureCode` seguro.

## 5. Configuração de produto

Arthur deve fornecer uma fonte central, ou valores carregados do backend, para:

- raio de descoberta; fallback atual: 30 km;
- pesos do ranking; referência atual: 80% afinidade e 20% proximidade;
- limiar de afinidade alta; não existe fallback inventado no app;
- intervalo de localização, se mudar o fallback atual de 15 minutos.

O limiar de afinidade alta é obrigatório para `MatchPolicy` e precisa ser
decidido pelo produto/Backend A.

## 6. Composição Riverpod

Após criar os adaptadores, sobrescrever os providers no escopo autenticado:

```dart
ProviderScope(
  overrides: [
    spotifyRepositoryProvider.overrideWithValue(spotifyRepository),
    discoveryRepositoryProvider.overrideWithValue(discoveryRepository),
    ownLocationRepositoryProvider.overrideWithValue(locationRepository),
    likeRepositoryProvider.overrideWithValue(likeRepository),
  ],
  child: const AuthenticatedApp(),
);
```

Ao logout:

1. chamar `spotifyRepository.disconnect()` se o produto decidir remover a
   conexão local nessa ação;
2. chamar `locationRepository.dispose()`;
3. destruir o `ProviderScope` autenticado;
4. encerrar a sessão Supabase.

Não use singletons globais que sobrevivam à troca de conta.

## 7. Testes que Arthur deve adicionar

### Banco/RPC

- usuário A não escreve localização de B;
- A não lê coordenadas exatas de B;
- descoberta devolve apenas `distanceKm`;
- usuário sem posição recebe erro mapeável;
- bloqueados/inativos não aparecem;
- duas curtidas simultâneas criam somente um match e uma conversa;
- repetir a RPC de curtir devolve a conversa existente;
- RLS impede leitura/escrita sem sessão.

### Integração Flutter

- serializar e desserializar um perfil musical real;
- mapear retorno real da descoberta para `DiscoveryCandidate`;
- mapear todos os erros Supabase para os enums do Backend B;
- validar os overrides Riverpod ao entrar e sua destruição no logout;
- executar o roteiro de duas contas em `docs/testing-backend-b.md`.

## 8. Definition of done conjunta

- duas contas reais aparecem uma para a outra quando elegíveis;
- cards mostram afinidade e distância segura;
- perfil completo mostra artistas e músicas salvos;
- cache musical funciona quando Spotify está temporariamente indisponível;
- GPS negado/desligado não causa crash;
- nenhuma coordenada de terceiro chega ao Flutter;
- curtir sempre retorna os três campos acordados;
- conversa não duplica;
- `flutter analyze` e `flutter test` continuam aprovados;
- os testes de RLS/RPC do Arthur passam no Supabase.
