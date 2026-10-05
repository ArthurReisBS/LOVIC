# Como testar o Backend B do Léo

## 1. Validação que funciona agora

Na raiz do projeto Flutter:

```bash
cd /home/armageddon/Lovic/LOVIC
flutter pub get
flutter analyze
flutter test
```

Resultado de referência desta branch:

- `flutter analyze`: `No issues found`;
- `flutter test`: 55 testes aprovados;
- `git status --short`: vazio depois dos commits.

Para descobrir exatamente qual caso falhou, use saída expandida:

```bash
flutter test --reporter expanded
```

## 2. Testes por funcionalidade

```bash
# Perfil musical, normalização e JSON
flutter test test/features/music_profile

# Spotify: PKCE, refresh, cache, 401 e rate limit
flutter test test/features/spotify

# Afinidade 50/30/20
flutter test test/features/affinity

# Descoberta, raio e ranking 80/20
flutter test test/features/discovery

# GPS próprio, erros, throttle e troca de sessão
flutter test test/features/location

# Curtir/Match e contrato de resposta
flutter test test/features/matches

# Smoke test do aplicativo
flutter test test/widget_test.dart
```

Esses testes não usam Spotify ou Supabase reais. Eles validam as regras, os
contratos, a segurança do OAuth e o comportamento das camadas com adaptadores
controlados.

## 3. Smoke test visual atual

Com emulador ou aparelho conectado:

```bash
flutter devices
flutter run -d <id-do-dispositivo>
```

Confirme que o aplicativo abre na tela de login e que não ocorre crash. O feed
visual ainda usa `mockProfiles`, marcado como `// MOCK`. Isso é apenas a
apresentação antiga: não comprova descoberta, Spotify, GPS ou match reais.

## 4. O que é necessário para um teste real

Antes do teste ponta a ponta, precisam existir:

1. adaptadores Supabase do Arthur para perfil musical, descoberta, localização
   e curtir;
2. overrides dos providers de `lib/app/backend_b_providers.dart` dentro da
   sessão autenticada;
3. telas da Isabelle consumindo os providers em vez dos mocks;
4. client ID público e redirect HTTPS cadastrados no Spotify;
5. App Link/Universal Link para o mesmo redirect;
6. duas contas de teste com dados cadastrais, localizações e perfis musicais.

## 5. Roteiro ponta a ponta depois da integração

### Conta A

1. Entrar na conta A.
2. Abrir Meu Perfil.
3. Ver estado `notConnected` e tocar em conectar.
4. Autorizar no Spotify e retornar ao app.
5. Confirmar estado `connected`, artistas, músicas, gêneros e `syncedAt`.
6. Fechar e reabrir Meu Perfil; o perfil salvo deve aparecer sem nova chamada
   obrigatória ao Spotify.
7. Permitir localização e entrar na descoberta.

### Conta B

1. Repetir conexão Spotify e envio de localização.
2. Manter as duas contas dentro do raio configurado.

### Descoberta e perfil

1. Na conta A, confirmar que B aparece com `affinity` entre 0 e 100 e
   `distanceKm`, sem latitude/longitude.
2. Confirmar a ordenação final por ranking 80/20.
3. Abrir B e conferir artistas, músicas, gêneros e data de sincronização.
4. Testar lista vazia afastando B ou reduzindo o raio.
5. Desligar a rede e verificar estado de erro, nunca fallback para mock.

### Localização

1. Negar permissão: resultado `permissionDenied`, sem crash.
2. Desligar o serviço GPS: resultado `serviceDisabled`.
3. Permitir: primeira entrada envia a posição própria.
4. Reabrir antes de 15 minutos: resultado `throttled`.
5. Trocar de conta durante uma captura: a operação antiga deve ser cancelada e
   nunca gravada na conta nova.

### Curtir e match

1. A curte B: conferir `deuMatch: false`, `conversationId: null` e
   `reason: no_match`, quando aplicável.
2. B curte A: conferir match com uma conversa preenchida e motivo confirmado.
3. Repetir a curtida rapidamente: deve existir apenas uma conversa para a dupla.
4. Expirar a sessão: a UI deve receber `LikeFailureCode.sessionExpired`.

## 6. Evidências para anexar na entrega

- saída de `flutter analyze`;
- saída final de `flutter test`;
- vídeo curto das duas contas aparecendo na descoberta;
- captura do JSON de descoberta sem coordenadas de terceiros;
- captura do retorno de curtir com os três campos;
- comprovação de que nenhum token/client secret aparece em logs ou commits.
