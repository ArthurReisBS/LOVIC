# Localização própria

Depois que Isabelle confirmar a permissão, chamar
`LocationRepository.updateOwnLocation(permissionGranted: true)` ao entrar ou
voltar à descoberta, ou logo após autorizar localização. Com `false`, nenhum GPS
ou backend é acessado. O data source Geolocator confere novamente permissão e
serviço antes de ler, mas nunca solicita permissão.

O repositório é o ponto único de envio para `OwnLocationWriter.saveOwnPosition`.
Arthur implementa essa porta com a sessão autenticada, grava apenas a posição do
próprio dono e mantém RLS. O método não recebe um `userId` arbitrário. Coordenadas
não aparecem no resultado para a tela nem nos perfis de descoberta.

`LocationUpdatePolicy.minimumInterval` centraliza o fallback de 15 minutos.
Primeira chamada autorizada envia; chamadas antes do intervalo não releem GPS.
Somente envio bem-sucedido avança o intervalo; falhas permitem tentar novamente.
Chamadas simultâneas compartilham uma leitura/envio. Instanciar com escopo de
sessão e chamar `dispose()` no logout/troca de conta. O writer de Arthur deve
capturar essa mesma sessão, nunca consultar uma sessão global mutável no momento
da escrita. Não há timer, coleta em background ou transmissão automática
enquanto o app está fechado.

Estados para Isabelle: `updated`, `throttled`, `permissionDenied`,
`serviceDisabled`, `readFailed`, `networkError`, `cancelled`; loading pertence ao provider
enquanto o Future está pendente. O resultado traz `updatedAt`/`nextUpdateAt`
quando aplicável, sem coordenadas.

Data source real: `GeolocatorLocationDataSource`, dependência `geolocator`.
Configuração nativa: Android `ACCESS_COARSE_LOCATION`; iOS
`NSLocationWhenInUseUsageDescription` com texto do produto; macOS precisa
descrição e entitlement quando essa plataforma fizer parte da entrega.
Na web o navegador precisa de um contexto seguro (HTTPS ou localhost).
Usar somente acesso em foreground; não habilitar permissão de background.
Referência: https://pub.dev/packages/geolocator.
