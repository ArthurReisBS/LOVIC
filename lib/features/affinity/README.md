# Afinidade musical

O serviço puro `AffinityService.calculate` recebe dois `MusicProfile` e entrega
`AffinityResult`. Telas, descoberta e curtir devem consumir `result.score` e os
subtotais/itens em comum, sem recalcular a fórmula.

## Fórmula adotada

Não havia uma fórmula implementada no repositório. A comparação escolhida para
esta primeira implementação é Jaccard por componente: quantidade de itens em
comum dividida pela quantidade de itens distintos na união dos dois perfis.

`score = 100 × (0.50 × artistas + 0.30 × gêneros + 0.20 × músicas)`

Os pesos permanecem exatamente os planejados: artistas 50%, gêneros 30% e
músicas 20%. Cada subtotal exposto (`artistScore`, `genreScore`, `trackScore`)
está em `0..100`, antes de aplicar seu peso; o resultado final também está em
`0..100`, sem arredondamento obrigatório. A apresentação decide quantas casas
mostrar; descoberta e match consomem o valor calculado.

## Normalização e ausência de dados

- Artistas e músicas são comparados por ID Spotify, preservando maiúsculas e
  minúsculas porque IDs são identificadores opacos. Apenas espaços nas bordas
  são removidos; IDs vazios são ignorados.
- Gêneros usam minúsculas e espaços normalizados (inclusive espaços repetidos).
- Duplicatas contam uma única vez. Ordem e nomes/imagens não alteram o cálculo.
- A lista dos identificadores/gêneros em comum é ordenada para tornar o resultado
  determinístico e independe da ordem dos perfis.
- Se a união de um componente está vazia, o componente vale zero: ausência de
  dados não significa compatibilidade. Se só um perfil está vazio, também vale
  zero. Os pesos não são redistribuídos; dois perfis contendo apenas os mesmos
  artistas atingem 50, e dois perfis totalmente vazios atingem zero.

Esta regra não consulta serviços externos nem persiste curtidas ou matches.
