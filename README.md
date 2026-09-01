# LOVIC

> Criando conexões a partir da arte musical

**LOVIC** é um aplicativo de relacionamentos que usa o **gosto musical** como principal critério de afinidade. Em vez de partir da foto, o app analisa os artistas e gêneros mais ouvidos de cada usuário e sugere perfis.

Dois pilares sustentam a proposta:

* **Integração com streaming** (Spotify / Apple Music), para levantar o perfil musical automaticamente, sem formulário
* **Geolocalização (GPS)**, para que as recomendações sejam de pessoas por perto e o encontro real seja viável

---

## Integrantes e papéis

| Integrante   | RM         | Responsabilidade neste CheckPoint                               |
| ------------ | ---------- | --------------------------------------------------------------- |
| **Arthur**   | `RM562181` | Repositório, README e estrutura de pastas do projeto            |
| **Isabelle** | `RM566464` | Documentação inicial: problema, público-alvo e definição do MVP |
| **Carol**    | `RM564651` | Marca: nome, *naming rationale* e tom de voz                    |
| **Léo**      | `RM563663` | Identidade visual: logo, paleta de cores e tipografia           |
| **Manoella** | `RM564469` | Pitch: modelo de negócio e diferencial competitivo              |
| **Júlia**    | `RM565010` | Projeto Flutter inicial e consolidação da entrega               |

---

## Estrutura do repositório

```text
.

├── docs/          # documentação escrita: problema, público-alvo, MVP e marca
├── design/        # logo, paleta de cores e tipografia
├── lib/           # código-fonte do app Flutter
└── README.md
```

### Documentação

| Documento                                                      | Conteúdo                                                          | Responsável |
| -------------------------------------------------------------- | ----------------------------------------------------------------- | ----------- |
| [`docs/problema-publico-mvp.md`](docs/problema-publico-mvp.md) | Problema que o app resolve, público-alvo e funcionalidades do MVP | Isabelle    |
| [`docs/marca.md`](docs/marca.md)                               | *Naming rationale* e tom de voz da marca                          | Carol       |
| [`docs/pitch.md`](docs/pitch.md)                               | Modelo de negócio e diferencial competitivo                       | Manoella    |
| [`design/`](design/)                                           | Logo, paleta de cores (hex) e tipografia                          | Léo         |

---

# 2. Documentação inicial: problema, público-alvo e MVP

## Problema

Atualmente, muitos aplicativos de relacionamento utilizam principalmente características visuais, como fotos e informações básicas, para realizar suas recomendações. Embora esses elementos possam ser importantes, eles não necessariamente representam os interesses, a personalidade ou os pontos de conexão entre duas pessoas.

Isso pode tornar a experiência de relacionamento mais superficial e dificultar a criação de conexões baseadas em interesses realmente compartilhados.

O **LOVIC** busca solucionar esse problema utilizando a **música como um indicador de afinidade**. Por meio da integração com plataformas de streaming, o aplicativo poderá analisar os artistas e gêneros mais ouvidos pelo usuário e utilizar essas informações para identificar pessoas com gostos musicais semelhantes.

Além disso, a utilização da **geolocalização** permite priorizar pessoas que estejam próximas, tornando as conexões mais relevantes e aumentando a possibilidade de que uma afinidade virtual possa se transformar em um encontro no mundo real.

### Problema central

> **Como facilitar a criação de conexões mais significativas entre pessoas utilizando interesses musicais reais, em vez de depender principalmente de características visuais?**

O LOVIC propõe responder a esse problema combinando três elementos principais:

* **Afinidade musical**, baseada nos hábitos reais de escuta;
* **Compatibilidade entre usuários**, calculada a partir dos perfis musicais;
* **Proximidade geográfica**, para facilitar possíveis encontros presenciais.

---

## Público-alvo

O público-alvo inicial do LOVIC é composto principalmente por **jovens adultos entre 18 e 35 anos** que possuem interesse em música, utilizam plataformas de streaming e demonstram interesse em conhecer novas pessoas.

O público inclui usuários que:

* Utilizam plataformas de streaming de música, como Spotify ou Apple Music;
* Possuem interesse em conhecer novas pessoas e estabelecer relacionamentos;
* Consideram a música uma parte relevante de seus interesses e identidade pessoal;
* Já possuem familiaridade com aplicativos de relacionamento;
* Valorizam encontrar pessoas com interesses em comum;
* Possuem interesse em conexões presenciais com pessoas que estejam geograficamente próximas.

### Perfil do usuário

O usuário ideal do LOVIC é uma pessoa que utiliza serviços de streaming com frequência e possui um histórico musical capaz de representar seus gostos e preferências.

Em vez de precisar responder a diversos questionários para informar seus interesses, o usuário poderá permitir que o aplicativo utilize seus dados musicais para construir automaticamente seu perfil de afinidade.

Dessa forma, a música deixa de ser apenas uma informação complementar no perfil e passa a ser um dos principais elementos utilizados para encontrar possíveis conexões.

---

# MVP — Minimum Viable Product

O **MVP (Minimum Viable Product)** do LOVIC será composto pelas funcionalidades essenciais para validar a proposta de conectar pessoas através da afinidade musical.

## 1. Cadastro e login

Permitir que o usuário crie uma conta e acesse o aplicativo de forma segura.

O cadastro deverá possibilitar a criação do perfil básico necessário para utilizar os recursos de relacionamento e afinidade musical.

## 2. Integração com plataformas de streaming

Permitir a conexão da conta do usuário com serviços como **Spotify e Apple Music**, possibilitando a obtenção automática de informações relacionadas ao seu gosto musical.

Entre os dados que poderão ser utilizados estão:

* Artistas mais ouvidos;
* Gêneros musicais predominantes;
* Preferências musicais gerais;
* Histórico ou indicadores de consumo musical disponibilizados pela plataforma.

Essa integração reduz a necessidade de preenchimento manual e permite que o perfil musical seja construído a partir dos hábitos reais do usuário.

## 3. Perfil musical

A partir dos dados obtidos pelas plataformas de streaming, o aplicativo deverá construir uma representação do gosto musical de cada usuário.

O perfil poderá considerar artistas e gêneros predominantes para identificar padrões de preferência.

Esse perfil será utilizado como base para comparar diferentes usuários e identificar possíveis afinidades.

## 4. Cálculo de afinidade musical

O aplicativo deverá comparar os perfis musicais dos usuários e gerar um **índice de afinidade**, permitindo identificar o quanto duas pessoas possuem gostos musicais semelhantes.

A comparação poderá considerar fatores como:

* Artistas em comum;
* Gêneros musicais em comum;
* Similaridade geral entre os perfis musicais;
* Peso das preferências mais relevantes de cada usuário.

Quanto maior a compatibilidade entre os perfis, maior será o nível de afinidade apresentado pelo aplicativo.

## 5. Geração de matches

Com base no índice de afinidade, o LOVIC poderá apresentar possíveis conexões entre os usuários.

O MVP prevê duas formas principais de interação:

### Match manual

O usuário visualiza um perfil recomendado e decide se possui interesse na conexão.

### Match automático

Quando a afinidade musical atingir um nível considerado muito alto, o aplicativo poderá destacar ou gerar automaticamente uma sugestão de conexão.

Essa funcionalidade representa um dos principais diferenciais do LOVIC, pois o match não dependerá exclusivamente da avaliação visual do perfil.

## 6. Geolocalização

Utilizar o GPS do dispositivo para identificar a localização aproximada do usuário e priorizar recomendações de pessoas que estejam próximas.

A localização será utilizada como um fator complementar à afinidade musical, buscando equilibrar:

**compatibilidade de gostos + proximidade geográfica.**

O objetivo é aumentar a relevância das recomendações e facilitar a possibilidade de transformar uma conexão virtual em um encontro presencial.

---

## Resumo do MVP

| Funcionalidade               | Objetivo                                     |
| ---------------------------- | -------------------------------------------- |
| **Cadastro e login**         | Criar e autenticar usuários                  |
| **Integração com streaming** | Obter automaticamente os gostos musicais     |
| **Perfil musical**           | Representar as preferências de cada usuário  |
| **Cálculo de afinidade**     | Comparar gostos musicais                     |
| **Match manual**             | Permitir que o usuário escolha suas conexões |
| **Match automático**         | Destacar conexões com alta afinidade         |
| **Geolocalização**           | Priorizar pessoas próximas                   |

> **Proposta central do MVP:** testar se a combinação entre **afinidade musical + proximidade geográfica** é capaz de gerar conexões mais relevantes do que recomendações baseadas predominantemente em características visuais.

---

## O MVP

Funcionalidades mínimas para o app fazer sentido:

* Cadastro e login
* Integração com Spotify / Apple Music — leitura dos artistas e gêneros mais ouvidos
* Cálculo de afinidade musical entre perfis
* Geração de matches: manual e automático quando a afinidade for alta
* Uso do GPS para exibir pessoas próximas

> O detalhamento do público-alvo e do MVP está em [`docs/problema-publico-mvp.md`](docs/problema-publico-mvp.md).

---

## Tecnologia

* **Flutter** (Dart) — aplicação multiplataforma
* APIs de streaming musical para o perfil de gosto
* Serviços de geolocalização do dispositivo

### Rodando o projeto

```bash
flutter pub get

flutter run
```

Requer o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
