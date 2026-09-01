# Documentação inicial — Problema, Público-alvo e MVP

## 1. Problema

Atualmente, grande parte dos aplicativos de relacionamento utiliza principalmente características visuais para apresentar e conectar pessoas. Embora fotos sejam importantes para uma primeira impressão, esse modelo pode favorecer julgamentos superficiais e não considerar interesses e características que realmente contribuem para a criação de uma conexão.

O **LOVIC** propõe uma abordagem diferente: utilizar a **afinidade musical** como um dos principais critérios para aproximar pessoas. A música está diretamente relacionada à personalidade, aos interesses e às experiências individuais, podendo servir como um ponto de partida mais natural para uma conversa e para a construção de uma conexão.

Por meio da integração com plataformas de streaming, como Spotify e Apple Music, o aplicativo poderá identificar os artistas, gêneros e estilos musicais mais ouvidos pelo usuário. Essas informações serão utilizadas para encontrar pessoas com gostos semelhantes.

Além disso, a utilização da **geolocalização** permite priorizar usuários que estejam próximos, tornando as conexões mais viáveis também fora do ambiente virtual.

### Problema central

> **Como facilitar a criação de conexões mais significativas entre pessoas utilizando interesses musicais reais, em vez de depender principalmente de características visuais?**

---

## 2. Público-alvo

O público-alvo do LOVIC é composto principalmente por **jovens adultos entre 18 e 35 anos** que utilizam aplicativos de relacionamento e plataformas de streaming de música.

O aplicativo é direcionado especialmente para pessoas que:

* utilizam serviços como Spotify ou Apple Music;
* consideram a música uma parte importante de sua identidade e rotina;
* gostam de descobrir novas músicas, artistas e gêneros;
* valorizam interesses em comum durante a criação de relacionamentos;
* desejam conhecer pessoas com gostos musicais semelhantes;
* possuem interesse em conexões presenciais com pessoas próximas geograficamente;
* procuram uma alternativa aos aplicativos de relacionamento baseados predominantemente em aparência.

O público também inclui usuários que acreditam que interesses em comum podem facilitar o início de uma conversa e tornar a experiência de conhecer novas pessoas mais natural.

---

## 3. MVP — Produto Mínimo Viável

O **MVP (Minimum Viable Product)** do LOVIC terá como objetivo validar a principal proposta do aplicativo: **conectar pessoas com base em sua afinidade musical e proximidade geográfica**.

Para isso, a primeira versão deverá possuir as funcionalidades essenciais para permitir que o usuário crie seu perfil, conecte sua conta musical e encontre pessoas compatíveis.

### 3.1 Cadastro e login

O usuário deverá conseguir criar uma conta e realizar login no aplicativo.

Informações básicas poderão ser utilizadas para a criação do perfil, como:

* nome;
* idade;
* foto de perfil;
* localização;
* informações básicas sobre o usuário.

---

### 3.2 Integração com plataformas de streaming

O aplicativo deverá permitir a integração com plataformas de streaming, inicialmente considerando **Spotify e/ou Apple Music**.

A integração terá como objetivo obter informações sobre os hábitos musicais do usuário, como:

* artistas mais ouvidos;
* gêneros musicais;
* músicas mais reproduzidas;
* preferências musicais.

Esses dados serão utilizados para construir o perfil musical do usuário.

---

### 3.3 Perfil musical

Além das informações tradicionais de um aplicativo de relacionamento, o usuário terá um **perfil musical**.

Esse perfil poderá apresentar:

* principais artistas;
* principais gêneros;
* músicas favoritas;
* nível de afinidade musical com outros usuários.

Dessa forma, a música passa a ser um elemento central da identidade do perfil.

---

### 3.4 Cálculo de afinidade

O sistema deverá comparar as preferências musicais dos usuários para determinar um **nível de compatibilidade**.

A afinidade poderá considerar fatores como:

* artistas em comum;
* gêneros musicais em comum;
* músicas compartilhadas;
* proximidade entre os estilos musicais dos usuários.

O resultado poderá ser apresentado por meio de uma porcentagem ou indicador de compatibilidade.

**Exemplo:**

> 🎵 Afinidade musical: **87%**

Quanto maior a afinidade, maior a prioridade do usuário nos resultados de possíveis conexões.

---

### 3.5 Matching

Com base nas informações musicais coletadas, o aplicativo deverá apresentar possíveis combinações entre os usuários.

O matching poderá considerar dois fatores principais:

**Afinidade musical + proximidade geográfica**

Isso permitirá que o sistema priorize pessoas que possuem gostos musicais semelhantes e estejam próximas umas das outras.

---

### 3.6 Geolocalização

O aplicativo utilizará a localização do usuário para identificar pessoas próximas.

A geolocalização poderá ser utilizada para:

* definir um raio de busca;
* priorizar usuários próximos;
* facilitar possíveis encontros presenciais;
* combinar proximidade com afinidade musical.

A localização exata do usuário não deverá ser exposta diretamente para outros usuários, sendo utilizada apenas para o funcionamento do sistema de matching.

---

## 4. Resumo do MVP

| Funcionalidade           | Objetivo                                    |
| ------------------------ | ------------------------------------------- |
| Cadastro e login         | Permitir acesso e criação do perfil         |
| Integração com streaming | Coletar dados sobre preferências musicais   |
| Perfil musical           | Apresentar os gostos musicais do usuário    |
| Cálculo de afinidade     | Identificar usuários com gostos semelhantes |
| Matching                 | Apresentar possíveis conexões               |
| Geolocalização           | Priorizar pessoas próximas                  |
| Combinação dos critérios | Unir afinidade musical e proximidade        |

---

## 5. Proposta de valor

O principal diferencial do LOVIC é utilizar a **música como ponto de partida para conexões entre pessoas**.

Em vez de depender exclusivamente da aparência para gerar interesse, o aplicativo utiliza dados reais de consumo musical para encontrar interesses compartilhados.

Assim, a proposta do LOVIC é:

> **Criar conexões a partir daquilo que as pessoas sentem, escutam e compartilham através da música.**
