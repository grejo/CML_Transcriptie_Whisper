# CML Transcriptie Tool - macOS Apple Silicon

Automatische transcriptie van audio- en videobestanden naar Word documenten met WhisperX.
Deze versie is specifiek voor **macOS met Apple Silicon (M1/M2/M3/M4)**.

> Samengesteld door **[Hogeschool PXL](https://www.pxl.be/) - Zorginnovatie**

> Andere versies: [Windows](https://github.com/grejo/CML_Transcriptie_Whisper_Windows) | [macOS Intel](https://github.com/grejo/CML_Transcriptie_Whisper_Intel)

---

## Installatie

### Vereisten

- macOS met Apple Silicon chip (M1, M2, M3 of M4)
- [Homebrew](https://brew.sh) moet geinstalleerd zijn

### Stappen

1. **Download het project**

   Klik op de groene knop **"Code"** bovenaan deze pagina en kies **"Download ZIP"**.
   Pak het ZIP-bestand uit in een map naar keuze, bijvoorbeeld `~/Documents/Github/`.

   Of via Terminal:
   ```bash
   cd ~/Documents/Github
   git clone https://github.com/grejo/CML_Transcriptie_Whisper.git
   ```

2. **Start de tool**

   Open Finder, navigeer naar de uitgepakte map en **dubbelklik op `start.command`**.

   > Bij de eerste keer kan macOS een beveiligingswaarschuwing tonen.
   > Klik dan met de **rechtermuisknop** op `start.command` > **Open** > **Open**.
   > Dit hoef je maar 1 keer te doen.

3. **Eerste keer: automatische installatie**

   Bij de eerste start worden automatisch geinstalleerd:
   - Python 3 (via Homebrew, als het nog niet aanwezig is)
   - ffmpeg (voor video-naar-audio conversie)
   - Alle Python-afhankelijkheden (WhisperX, PyTorch, etc.)

   Dit kan **5-10 minuten** duren. Daarna starten volgende keren direct.

4. **Snelkoppeling**

   Na de eerste start wordt automatisch een snelkoppeling aangemaakt in `~/Applications/`.
   Je kunt de tool daarna ook starten door te dubbelklikken op **`CML Transcriptie.command`** in die map.

---

## Gebruik

Na het opstarten worden er twee vragen gesteld:

### 1. Kies de taal

```
  1. Nederlands (nl)  (standaard)
  2. English (en)
  3. Francais (fr)
  ...
```

Typ het nummer van de taal en druk op Enter. Standaard is Nederlands.

### 2. Kies het model

```
  1. tiny       - 39M params   - Snelst, basis kwaliteit
  2. base       - 74M params   - Snel, redelijke kwaliteit
  3. small      - 244M params  - Goede kwaliteit
  4. medium     - 769M params  - Zeer goed (aanbevolen)
  5. large      - 1550M params - Beste kwaliteit, langzaam
  6. large-v3   - 1550M params - Nieuwste, beste voor NL
```

Typ het nummer en druk op Enter. Standaard is `medium` (aanbevolen).

> **Tip:** Gebruik `tiny` of `base` om snel te testen. Gebruik `large-v3` voor de beste kwaliteit.

### 3. Selecteer een bestand

Een Finder-venster wordt geopend. Selecteer een audio- of videobestand.

**Ondersteunde formaten:**
- Audio: MP3, WAV, M4A, OGG, FLAC, AAC
- Video: MP4, MOV, AVI, MKV, WEBM, FLV, WMV

### 4. Wacht op de transcriptie

De voortgang wordt getoond met een gedetailleerde progressiebalk:

```
  Transcriptie: [===============>          ]  45.67%
```

Bij video's wordt eerst het geluid geextraheerd, daarna getranscribeerd.

### 5. Resultaat

Het Word-document wordt automatisch opgeslagen in je **Downloads-map** (`~/Downloads/`) met dezelfde naam als het bronbestand. Finder opent automatisch bij het bestand.

---

## Veelgestelde vragen

**Hoe lang duurt een transcriptie?**
Dat hangt af van de duur van het audiobestand en het gekozen model. Een schatting wordt getoond voor de start. Met het `medium` model duurt het ongeveer 1.5x de lengte van de audio.

**Kan ik het programma afbreken?**
Ja, druk op `Ctrl+C` in het Terminal-venster.

**Waar worden de modellen opgeslagen?**
In `~/.cache/huggingface/`. De eerste keer dat je een model gebruikt wordt het gedownload (500MB - 3GB afhankelijk van het model).

**Het script start niet bij dubbelklikken?**
Rechtermuisklik > Open > Open. macOS blokkeert onbekende scripts standaard.

**Ik wil opnieuw beginnen met een schone installatie?**
Verwijder de `venv` map in de projectmap en start opnieuw.

---

## Bouwstenen

Deze tool is opgebouwd met de volgende open-source componenten:

| Component | Beschrijving | Link |
|---|---|---|
| **WhisperX** | Snelle spraakherkenning met woordniveau-timestamps, gebaseerd op OpenAI Whisper | [github.com/m-bain/whisperX](https://github.com/m-bain/whisperX) |
| **OpenAI Whisper** | Het onderliggende spraakherkenningsmodel van OpenAI | [github.com/openai/whisper](https://github.com/openai/whisper) |
| **Faster Whisper** | CTranslate2-backend voor snellere inferentie van Whisper-modellen | [github.com/SYSTRAN/faster-whisper](https://github.com/SYSTRAN/faster-whisper) |
| **CTranslate2** | Geoptimaliseerde inferentie-engine voor Transformer-modellen | [github.com/OpenNMT/CTranslate2](https://github.com/OpenNMT/CTranslate2) |
| **PyTorch** | Machine learning framework | [pytorch.org](https://pytorch.org/) |
| **Hugging Face Transformers** | Platform voor het laden van voorgetrainde AI-modellen | [huggingface.co](https://huggingface.co/) |
| **FFmpeg** | Audio- en videoconversie | [ffmpeg.org](https://ffmpeg.org/) |
| **python-docx** | Word-documenten genereren vanuit Python | [github.com/python-openxml/python-docx](https://github.com/python-openxml/python-docx) |
| **librosa** | Audioanalyse en -verwerking | [github.com/librosa/librosa](https://github.com/librosa/librosa) |
