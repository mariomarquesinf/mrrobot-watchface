[🇬🇧 English](README.md) | [🇵🇹 Português](README.pt.md)

# Mr. Robot Terminal — Watch Face para Wear OS

[![Build](https://github.com/mariomarquesinf/mrrobot-watchface/actions/workflows/build.yml/badge.svg)](https://github.com/mariomarquesinf/mrrobot-watchface/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Criado por [Mário Marques](https://mariomarquesinf.com) — [mariomarquesinf.com](https://mariomarquesinf.com)

Uma watch face totalmente declarativa e sem código executável para Wear OS, com a
estética hacker/terminal da série **Mr. Robot** (fsociety). Construída inteiramente no
**Watch Face Format (WFF)** da Google — um grafo de cena em XML interpretado
nativamente pelo sistema operativo, sem serviço em segundo plano, sem código de
aplicação, e com impacto mínimo na bateria.

![Demo](docs/screenshots/demo.gif)

![As seis paletas de cor](docs/screenshots/all_themes.png)

## Porquê o Watch Face Format

Historicamente, a maioria das watch faces de terceiros para Wear OS era um serviço
Android em execução (um `WatchFaceService` com um ciclo de renderização, a executar
código a cada tick). O WFF inverte essa lógica: a watch face é um **documento XML
declarativo** — formas, texto, complicações e configuração de cor — que o próprio
renderizador do sistema desenha, exatamente como desenha as suas watch faces nativas.
Os compromissos que moldaram este projeto:

- **Nenhum código executável** (`android:hasCode="false"`) — toda a lógica visual e de
  ligação de dados vive em `app/src/main/res/raw/watchface.xml`.
- **Ciclo de vida gerido pelo sistema** — o modo ambiente, a proteção contra burn-in e a
  gestão de bateria são tratados pelo renderizador do SO, não por lógica própria.
- **Sem forma de fazer testes unitários.** Não existe runtime ao qual anexar um debugger
  ou uma test suite — a correção só pode ser verificada instalando o grafo de cena
  compilado num relógio real e observando o resultado. Todas as decisões de layout e de
  ligação de dados deste repositório foram validadas empiricamente via ADB (`logcat` ao
  vivo + screenshots no dispositivo), o que vale a pena saber antes de assumir que
  "renderiza" significa "está correto."
- **Validado por esquema em CI, não só testado manualmente.** O `aapt2` empacota sem
  problemas um `watchface.xml` que viola o esquema real do WFF — não detetou nada de
  errado com `isCustomizable="true"`, que é inválido (o esquema exige `TRUE`/`FALSE` em
  maiúsculas). Esse bug só foi encontrado ao correr o
  [validador XSD](https://github.com/google/watchface/tree/main/third_party/wff) oficial
  da Google contra o XML fonte — a mesma ferramenta usada para certificar watch faces
  para submissão na Play Store. Depois de corrigido, o `watchface.xml` **passa sem erros
  contra a versão 1 e também contra a versão 5 (a mais recente) do formato**. Esta
  verificação corre agora em cada push via [CI](.github/workflows/build.yml), pelo que
  uma futura regressão de esquema falha o build em vez de seguir para produção em
  silêncio.
- Também corri o avaliador
  [`memory-footprint`](https://github.com/google/watchface/tree/main/play-validations)
  da Google (a verificação de orçamento de memória da Play Store) contra o APK
  compilado. Encontrei o que parece ser um bug no próprio resolvedor de recursos dessa
  ferramenta para referências `PartImage` ao nível da cena — confirmado como um problema
  da ferramenta, não nosso, assim que o validador XSD acima deu ao XML um passe limpo.
  Rastreado até um ficheiro recentemente alterado nesse projeto, em vez de contornado às
  cegas.

## Funcionalidades

- **Estética de terminal/HUD hacker** — prompt `root@fsociety:~#`, saudação
  `HELLO, FRIEND.`, e um cursor no rodapé que pisca ao ritmo dos segundos (comportamento
  real de cursor de terminal, controlado por uma expressão `[SECOND] % 2`, não uma
  animação fixa).
- **Relógio digital em destaque** — mostrador `hh:mm:ss` grande e centrado, o elemento
  visual principal, com um breve pulso de glitch RGB (aberração cromática) a cada 10
  segundos (duas cópias "fantasma" do relógio, desviadas de cor, aparecem e desaparecem
  através de uma expressão `[SECOND] % 10`) — um toque VHS/hacker que remete diretamente
  para a estética do próprio logo da fsociety.
- **4 complicações reais e editáveis pelo utilizador** (data, batimentos, bateria,
  passos por defeito — livremente substituíveis por qualquer coisa que o sistema
  ofereça), organizadas numa grelha 2×2 reta e legível, em vez de texto curvado no bezel.
- **Marca de água com a máscara da fsociety**, renderizada como uma máscara de alpha
  monocromática para poder ser recolorida em tempo real de acordo com a cor de destaque
  do tema ativo, com opacidade baixa para permanecer um elemento de fundo.
- **Retícula HUD nos cantos** em vez de um simples aro circular.
- **Modo ambiente/always-on (AOD) real** — não é apenas uma cópia de baixo consumo não
  modificada da watch face interativa. Todo o HUD (marca de água, retícula, cabeçalho,
  linhas de estado, rodapé) desaparece por completo em modo ambiente, substituído por um
  relógio e data esbatidos e sem segundos; as 4 complicações mantêm-se visíveis mas
  esbatidas. Mantém-se bem abaixo da diretriz do Wear OS de 15% de pixels acesos em modo
  ambiente, e reduz o risco de burn-in em ecrãs AMOLED.
- **6 paletas de cor intercambiáveis**, alteráveis no próprio relógio sem qualquer
  alteração de código.

## Notas de arquitetura

Algumas decisões que vale a pena destacar, porque não foram a primeira abordagem
tentada:

- **O modo ambiente usa `Group`s paralelos alternados por `Variant`, não uma única cena
  reformatada.** O WFF não tem layout condicional ("se ambiente, faz X"); em vez disso
  declaram-se duas versões de uma sub-árvore — uma para modo interativo, outra para modo
  ambiente — cada uma com `<Variant mode="AMBIENT" target="alpha" value="…"/>` a alternar
  a sua própria visibilidade. O HUD interativo é um `Group` que passa a `alpha=0` em modo
  ambiente; o relógio/data de ambiente é um `Group` separado que começa em `alpha=0` e só
  aparece em modo ambiente. Os 4 `ComplicationSlot` ficaram fora de ambos os grupos
  (aninhá-los num `Group` não é um padrão documentado) e, em vez disso, o ícone/texto de
  cada um é esbatido diretamente através do mesmo mecanismo `Variant`.
- **As complicações mostram apenas o valor em bruto entre parênteses retos** (`[62]`,
  `[1189]`), nunca uma etiqueta de categoria fixa como `BAT:` ou `STP:`. As primeiras
  versões tinham uma etiqueta fixa por slot; o problema é que o utilizador pode
  reatribuir qualquer slot a uma fonte de dados *diferente* (por exemplo, trocar "data"
  pela pontuação de "prontidão" de uma app de fitness) através da interface padrão de
  personalização do Wear OS, e uma etiqueta fixa ficaria incorreta silenciosamente. Em
  vez disso, cada complicação mostra o ícone `MONOCHROMATIC_IMAGE` do próprio provedor
  atribuído, ao lado do valor — a etiqueta vem sempre do que está realmente selecionado,
  por isso nunca pode ficar dessincronizada.
- **Tematização centralizada.** Todos os elementos coloridos — texto, ícones, o tom da
  marca de água, as linhas divisórias — estão ligados a
  `[CONFIGURATION.themeColor.N]`. Adicionar um 7º tema significa adicionar um bloco
  `<ColorOption>`; nenhum outro ficheiro precisa de ser alterado.
- **O texto curvado no bezel foi tentado e revertido.** Uma iteração anterior desenhava
  os valores das complicações a envolver o bezel com `TextCircular`. Parecia correto no
  XML e correspondia à geometria documentada, mas era empiricamente ilegível no
  dispositivo — os caracteres rodam para se manterem tangentes ao arco, o que em
  tamanhos de letra pequenos perto das posições de 9/3 horas resulta em ruído
  ilegível. A correção não foi uma correção de bug, foi uma mudança de design: passar
  para texto horizontal reto.
- **Fallback de fonte entre dispositivos, corrigido ao nível dos metadados.** Um
  utilizador reportou que os tipos de letra não coincidiam num Galaxy Watch 6. O WFF
  resolve `Font family="…"` pelo *nome do ficheiro*, o que `roboto_mono_bold.ttf` e
  `roboto_mono_regular.ttf` já faziam corretamente — mas ao inspecionar os tipos de
  letra compilados (`fontTools`), ambos os ficheiros declaravam o *mesmo nome de
  família interno* ("Roboto Mono"), diferindo apenas na subfamília. O renderizador do
  Pixel Watch tolera isso; outras implementações de carregamento de fontes no Wear OS
  parecem des-duplicar/colocar em cache os tipos de letra pelo nome de família interno,
  o que colapsaria silenciosamente os dois pesos num só (ou falharia a resolver
  qualquer um deles, recorrendo à fonte do sistema — exatamente o sintoma reportado).
  Corrigido atribuindo a cada ficheiro um nome de família interno distinto, coincidente
  com o seu nome de ficheiro, sem necessidade de alterar XML ou nomes de ficheiro.
- **Interface de personalização localizada, não apenas em português fixo.** Todas as
  strings mostradas no seletor nativo de cores/complicações do Wear OS (nomes de temas,
  etiquetas dos slots) estavam fixas em português no `values/strings.xml` *default* —
  o Android recorre a esse ficheiro para qualquer idioma sem override próprio, pelo que
  utilizadores de língua inglesa (como quem encontra isto via Reddit, ou quem reportou
  o bug do Galaxy Watch 6 acima) viam "Cor do Terminal" e "Lavanda Neon" no seletor,
  independentemente do idioma do dispositivo. Movi as strings em inglês para o
  `values/strings.xml` default e adicionei um `values-pt/strings.xml` próprio para
  dispositivos em português — resolução de recursos padrão do Android, verificada no
  APK compilado via `aapt2 dump resources`. Também apanhei e corrigi um resquício
  esquecido ao fazer isto: a marca "(Padrão)" ainda estava na Lavanda, de antes do tema
  por defeito ter passado para o fsociety Vermelho.

## Paletas de cor

| Tema | Texto | Destaque | Escuro |
|---|---|---|---|
| fsociety Vermelho (padrão) | `#FFE4E6` | `#F43F5E` | `#881337` |
| Lavanda Neon | `#E9D5FF` | `#C084FC` | `#4C1D95` |
| Kali Verde Terminal | `#DCFCE7` | `#22C55E` | `#14532D` |
| Cyber Ciano | `#E0F2FE` | `#06B6D4` | `#164E63` |
| Fósforo Âmbar | `#FEF3C7` | `#F59E0B` | `#78350F` |
| Stealth Branco | `#FFFFFF` | `#CBD5E1` | `#334155` |

## Instalação

**APK pré-compilado:** obtém a versão mais recente em [Releases](../../releases) e
instala-a via sideload:
```bash
adb install mrrobot_watchface.apk
```
De seguida, mantém premida a watch face atual e seleciona **Mr. Robot Terminal**.

**Compilar a partir do código-fonte:**
```bash
./gradlew assembleDebug
```
ou, para um ciclo de iteração local mais rápido usando `aapt2` diretamente (ver
`tools/build_apk.ps1`):
```powershell
./tools/build_apk.ps1
```
Requer Wear OS 4+ (API 33+) no dispositivo de destino.

## Estrutura do projeto

```
watchFace/
├── app/
│   └── src/main/
│       ├── AndroidManifest.xml       # Declaração da versão do WFF, sem código
│       └── res/
│           ├── raw/watchface.xml     # Todo o grafo de cena: layout, complicações, tematização
│           ├── drawable/             # Ícone da app, preview da loja, marca de água
│           ├── font/                 # Tipos de letra personalizados de terminal/display
│           └── values/strings.xml    # Nomes dos temas e dos slots de complicação
├── tools/                            # Scripts locais de desenvolvimento (build rápido via aapt2, instalação ADB, preview de emulador)
├── docs/screenshots/                 # Galeria de temas
└── build.gradle.kts / settings.gradle.kts
```

## Licença

MIT — ver [LICENSE](LICENSE). "Mr. Robot" e "fsociety" pertencem aos respetivos
detentores dos direitos; este é um projeto de fã não oficial e sem fins comerciais.
