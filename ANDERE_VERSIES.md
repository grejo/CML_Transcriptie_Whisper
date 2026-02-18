# CML Transcriptie Tool - Andere Versies

Dit document beschrijft hoe je de tool kunt aanpassen voor andere platformen.
De huidige versie is gebouwd voor **macOS Apple Silicon (M1/M2/M3/M4)**.

---

## Huidige versie: macOS Apple Silicon

- **Bestand**: `start.command`
- **Architectuur**: arm64
- **Device**: CPU met int8 compute (CTranslate2 ondersteunt geen Apple MPS)
- **Dependency manager**: Homebrew + pip in venv
- **File dialog**: `osascript` (native macOS Finder dialoog)

---

## Versie 2: macOS Intel

### Aanpassingen in `start.command`

1. **Verwijder de arm64 check** of wijzig naar:
   ```bash
   if [ "$ARCH" != "x86_64" ]; then
       echo "FOUT: Dit programma is voor macOS Intel (x86_64)."
       exit 1
   fi
   ```

2. **Bestandsnaam**: `start_intel.command`

### Aanpassingen in `transcribe.py`

1. **Compute type**: Wijzig `compute_type = "int8"` naar `compute_type = "float32"`.
   Intel CPU's ondersteunen geen int8 via CTranslate2 standaard.

2. **Batch size**: Verlaag `batch_size = 16` naar `batch_size = 8` vanwege lagere performance op Intel.

3. **RTF_MAP**: Verhoog de waarden met factor 2-3x want Intel is trager:
   ```python
   RTF_MAP = {
       'tiny': 0.6,
       'base': 1.0,
       'small': 1.6,
       'medium': 3.0,
       'large': 5.0,
       'large-v3': 5.0,
   }
   ```

### Aanpassingen in `requirements.txt`

Geen wijzigingen nodig. Dezelfde packages werken op Intel.

---

## Versie 3: Windows

### Nieuw bestand: `start.bat`

Vervang `start.command` door een Windows batch script:

```bat
@echo off
title CML Transcriptie Tool

echo ============================================
echo   CML Transcriptie Tool - Setup
echo ============================================
echo.

REM Check Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo FOUT: Python is niet geinstalleerd.
    echo Download Python van https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Check ffmpeg
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo FOUT: ffmpeg is niet geinstalleerd.
    echo Download van https://ffmpeg.org/download.html
    echo Of installeer via: winget install ffmpeg
    pause
    exit /b 1
)

REM Maak venv
if not exist "venv" (
    echo Virtuele omgeving aanmaken...
    python -m venv venv
)

REM Activeer venv
call venv\Scripts\activate.bat

REM Check dependencies
python -c "import whisperx" 2>nul
if %errorlevel% neq 0 (
    echo Afhankelijkheden installeren...
    pip install --upgrade pip
    pip install -r requirements.txt
)

REM Start tool
python transcribe.py

pause
```

### Aanpassingen in `transcribe.py`

1. **File dialog**: Vervang `osascript` door `tkinter`:
   ```python
   def select_file_dialog():
       import tkinter as tk
       from tkinter import filedialog
       root = tk.Tk()
       root.withdraw()
       filetypes = [
           ("Audio/Video bestanden", " ".join(f"*{ext}" for ext in SUPPORTED_FORMATS)),
           ("Alle bestanden", "*.*")
       ]
       path = filedialog.askopenfilename(
           title="Selecteer een audio- of videobestand",
           filetypes=filetypes
       )
       root.destroy()
       return path if path else None
   ```

2. **Finder openen**: Vervang `subprocess.run(['open', '-R', ...])` door:
   ```python
   subprocess.run(['explorer', '/select,', str(output_path)])
   ```

3. **Device detectie**: Voeg CUDA-ondersteuning toe voor NVIDIA GPU's:
   ```python
   import torch
   if torch.cuda.is_available():
       device = "cuda"
       compute_type = "float16"
   else:
       device = "cpu"
       compute_type = "int8"
   ```

4. **Batch size**: Bij CUDA, verhoog `batch_size = 32` voor betere GPU-benutting.

5. **Snelkoppeling**: Plaats `start.bat` in het Startmenu of maak een `.lnk` snelkoppeling op het bureaublad.

### Aanpassingen in `requirements.txt`

Voor NVIDIA GPU ondersteuning, voeg toe:
```
--extra-index-url https://download.pytorch.org/whl/cu118
torch>=2.0.0
torchaudio>=2.0.0
```

---

## Versie 4: Linux (Ubuntu/Debian)

### Nieuw bestand: `start.sh`

```bash
#!/bin/bash
cd "$(dirname "$(readlink -f "$0")")"

echo "============================================"
echo "  CML Transcriptie Tool - Setup"
echo "============================================"

# Check Python 3
if ! command -v python3 &> /dev/null; then
    echo "Python 3 installeren..."
    sudo apt-get update && sudo apt-get install -y python3 python3-venv python3-pip
fi

# Check ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg installeren..."
    sudo apt-get update && sudo apt-get install -y ffmpeg
fi

# Check tkinter (nodig voor file dialog op Linux)
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "tkinter installeren..."
    sudo apt-get install -y python3-tk
fi

# Venv
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

if ! python -c "import whisperx" 2>/dev/null; then
    pip install --upgrade pip
    pip install -r requirements.txt
fi

python transcribe.py

read -p "Druk op Enter om af te sluiten..."
```

### Aanpassingen in `transcribe.py`

1. **File dialog**: Gebruik `tkinter` (zelfde als Windows versie hierboven)
2. **Finder openen**: Vervang door `xdg-open`:
   ```python
   subprocess.run(['xdg-open', str(output_path.parent)])
   ```
3. **Device**: Voeg CUDA-ondersteuning toe (zelfde als Windows)
4. **Desktop entry**: Maak een `.desktop` bestand voor dubbelklik:
   ```ini
   [Desktop Entry]
   Name=CML Transcriptie
   Exec=/pad/naar/start.sh
   Terminal=true
   Type=Application
   ```

---

## Samenvatting wijzigingen per versie

| Onderdeel | macOS ARM | macOS Intel | Windows | Linux |
|-----------|-----------|-------------|---------|-------|
| Launcher | `.command` | `.command` | `.bat` | `.sh` |
| Arch check | arm64 | x86_64 | - | - |
| Pkg manager | Homebrew | Homebrew | winget/handmatig | apt-get |
| File dialog | osascript | osascript | tkinter | tkinter |
| Bestand openen | `open -R` | `open -R` | `explorer /select,` | `xdg-open` |
| GPU | Nee (CPU int8) | Nee (CPU float32) | CUDA (indien NVIDIA) | CUDA (indien NVIDIA) |
| Compute type | int8 | float32 | float16 (CUDA) / int8 | float16 (CUDA) / int8 |
| Python | Via Homebrew/Xcode | Via Homebrew/Xcode | python.org / winget | apt-get |

---

## Tips

- Test elke versie op het doelplatform
- De eerste keer dat de tool draait worden WhisperX modellen gedownload (~500MB-3GB afhankelijk van gekozen model)
- Modellen worden gecached in `~/.cache/huggingface/` (macOS/Linux) of `%USERPROFILE%\.cache\huggingface\` (Windows)
- Bij problemen: verwijder de `venv` map en start opnieuw
