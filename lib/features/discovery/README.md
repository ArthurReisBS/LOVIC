# Descoberta e perfil de outra pessoa

`DiscoveryRepository.discover(viewer: MusicProfile)` recebe o perfil musical
próprio salvo, chama `DiscoveryDataSource.fetchNearby(radiusKm:)` e devolve
`DiscoveryResult`. A lista vem ordenada, imutável e enriquecida com afinidade.
`isEmpty` distingue ninguém por perto de um erro; `radiusKm` permite escrever a
mensagem de lista vazia com o raio realmente utilizado. Loading pertence ao
provider/frontend enquanto o Future está pendente.

Cada `DiscoveryProfile` expõe `id`, `name`, `age`, `bio`, `photoUrl`, `genres`,
`affinity` em 0..100 e `distanceKm`. Para a tela de perfil, também expõe `artists`,
`tracks` e `musicProfile.syncedAt`. `getProfile(viewer:, userId:)` reutiliza os
dados musicais salvos recebidos do Backend A, sem consultar Spotify.

Arthur implementa `DiscoveryDataSource`: busca apenas candidatos elegíveis, com
dados cadastrais, `MusicProfile` e distância em km já arredondada. O contrato não
aceita coordenadas de terceiros. A sessão e RLS continuam sendo validadas pelo
Backend A; o perfil musical deve ter o mesmo `userId` do candidato.

`DiscoveryConfig` é a fonte central do ranking: fallback documentado de 30 km e
pesos 80% afinidade / 20% proximidade. Arthur pode injetar os valores de produto.
A fórmula usa proximidade = `100 * (1 - distanceKm / radiusKm)`, limitada a
0..100. O raio é inclusivo. O próprio usuário e IDs repetidos são excluídos.
Empates usam afinidade, distância e ID para ordenar deterministicamente.

O adaptador deve mapear falhas para `DiscoveryDataException` com códigos
`network`, `sessionExpired`, `locationRequired`, `notFound` ou `unexpected`.
Erros técnicos não são devolvidos à tela e não existe fallback de perfis mockados.
