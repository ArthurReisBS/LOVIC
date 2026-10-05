# Curtir / Match — Backend B

`LikeRepository.like(targetUserId: ..., affinity: affinityResult.score)` recebe
o score já calculado pelo `AffinityService` e devolve `LikeResult` com exatamente
`deuMatch`, `conversationId` e `reason`. O id do ator vem da sessão autenticada
injetada por Arthur, não de um campo passado pela tela.

Os códigos propostos para integração são `mutual_like` (curtida mútua),
`high_affinity` (afinidade alta) e `no_match` (curtida recebida sem match).
`conversationId` é obrigatório/preenchido com match e nulo sem match.
Falhas de autenticação, transporte ou contrato geram erro, nunca um falso
`no_match`. A UI recebe `LikeFailure` com código `sessionExpired`,
`invalidRequest`, `invalidResponse` ou `unavailable`, sem payload técnico. Os
nomes/códigos de match precisam ser confirmados com Arthur/Isabelle antes
de ligar as telas; nenhuma API existente foi renomeada.

Arthur implementa a operação real de Supabase e a injeta por
`BackendALikeOperationDataSource`, traduzindo sua RPC para os três campos acima.
O PDF sugere a função `curtir`, mas não define nomes de parâmetros, schema de
banco nem resposta SQL: a camada B não inventa essas propriedades. A operação
de A usa a sessão autenticada para validar o ator, persiste a curtida, aplica
as regras e cria/retorna a conversa atomicamente. RLS, deduplicação persistente
e decisões sobre match pertencem ao Backend A.

`BackendLikeRepository` rejeita autocurtida/score inválido e compartilha chamadas
simultâneas para a mesma dupla. Depois de sucesso ou falha, uma nova chamada pode
consultar o backend; o backend deve devolver a mesma conversa para uma dupla
já associada. Não há persistência ou fake de produção nesta camada.

`MatchPolicy(highAffinityThreshold: ...)` permite testar/consultar o limiar
inclusivo em um único ponto, quando necessário. O valor deve vir da configuração
do produto/Arthur. O plano e o PDF não fixam um número: não há fallback numérico
nem decisão local que substitua a resposta do backend. Afinidade alta e curtida
mútua são motivos aceitos, mas sua precedência é decisão do produto/Backend A.

Limitação acadêmica: o score calculado no cliente pode ser adulterado. Validar
`0..100` localmente melhora o contrato, mas não é uma garantia de segurança;
Arthur deve validar ou recalcular o score no ambiente confiável quando necessário.
