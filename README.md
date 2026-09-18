# Mr. Robot Watch Face - Wear OS (Pixel Watch 4)

Watch face para Google Pixel Watch (Wear OS 4 / 5) inspirada na estética hacker e terminal da série **Mr. Robot** (fsociety).

Construída de raiz utilizando o formato oficial e moderno da Google: **Watch Face Format (WFF)** — declarativo em XML, com consumo mínimo de bateria, renderização nativa pelo sistema e sem código executável redundante.

---

## 📸 Pré-visualização

A watch face apresenta um design terminal Linux / fsociety:
- **Header Terminal**: `root@fsociety:~# ./time` acompanhado da frase icônica `hello, friend.`
- **Relógio Digital Central**: Horas, minutos e segundos (`HH:mm:ss`) em tipografia terminal mono com espaçamento proporcional.
- **Data do Sistema**: `SYS_DATE: YYYY.MM.DD`
- **Slots de Complicações**: 
  - **Topo**: Data / Evento / Calendário (`[ %s ]`)
  - **Inferior Esquerda**: Bateria do relógio com prefixo terminal (`[BAT: 84%]`)
  - **Inferior Direita**: Contador de passos / Atividade (`[STP: 8420]`)
- **Rodapé fsociety**: `fsociety.org // encrypted` e cursor de prompt `[ > _ ]`
- **Modo Always-On Display (AOD / Ambient)**: Otimizado para telas AMOLED — reduz os pixels iluminados a menos de 10%, oculta segundos e elementos decorativos, preservando bateria e prevenindo burn-in.

---

## 🎨 Seletor de Cores (Paletas Customizáveis)

O utilizador pode personalizar a cor diretamente nas opções do mostrador no Pixel Watch ou na app Google Pixel Watch no smartphone:

1. **Lavanda Neon (`#C084FC` / `#E9D5FF`) [PADRÃO / DEFAULT]**: Estética neon cyber-lavanda, vibrante e minimalista.
2. **fsociety Vermelho (`#F43F5E` / `#FFE4E6`)**: O tom clássico da máscara e estética de revolução do Mr. Robot / Evil Corp.
3. **Kali Verde Terminal (`#22C55E` / `#DCFCE7`)**: Verde fósforo clássico estilo terminal CRT e Kali Linux.
4. **Cyber Ciano (`#06B6D4` / `#E0F2FE`)**: Azul elétrico futurista.
5. **Fósforo Âmbar (`#F59E0B` / `#FEF3C7`)**: Visual âmbar retro de terminais VT100 dos anos 80.
6. **Branco Stealth (`#CBD5E1` / `#FFFFFF`)**: Alto contraste monocromático minimalista.

---

## 📂 Estrutura do Projeto

```
watchFace/
├── build.gradle.kts                     # Gradle raiz
├── settings.gradle.kts                  # Configuração de repositórios e módulos
├── gradle.properties
├── README.md
└── app/
    ├── build.gradle.kts                 # Módulo Wear OS (minSdk 33, targetSdk 34)
    └── src/
        └── main/
            ├── AndroidManifest.xml      # Declaração do formato WFF (com.google.wear.watchface.format.version = 1)
            └── res/
                ├── drawable/
                │   ├── ic_launcher.xml  # Ícone vetorial da aplicação (prompt fsociety)
                │   └── preview.jpg      # Imagem de pré-visualização para o seletor do relógio
                ├── raw/
                │   └── watchface.xml    # Ficheiro principal WFF declarativo (Cores, Relógio, Slots)
                ├── values/
                │   └── strings.xml      # Nomes das cores e identificadores dos slots
                └── xml/
                    └── watch_face_info.xml # Metadados Wear OS (suporte para edição e preview)
```

---

## 🚀 Como Executar / Instalar no Pixel Watch 4

### Opção 1: Via Android Studio
1. Abrir a pasta `F:\Dev\techIncubator\watchFace` no **Android Studio**.
2. Conectar o **Pixel Watch 4** através de **Wireless Debugging** (ADB via Wi-Fi) ou através do Emulador Wear OS.
3. Clicar em **Run** (`Shift + F10`).
4. O mostrador ficará imediatamente disponível na lista de mostradores do relógio.

### Opção 2: Linha de Comandos (ADB)
Após gerar o APK (`./gradlew assembleDebug`):
```bash
adb connect <IP_DO_PIXEL_WATCH>:5555
adb install app/build/outputs/apk/debug/app-debug.apk
```
Após a instalação, basta pressionar sem soltar o mostrador atual do Pixel Watch e selecionar o **Mr. Robot Terminal**.
