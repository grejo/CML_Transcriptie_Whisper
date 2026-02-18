#!/bin/bash
# CML Transcriptie Tool - Launcher voor macOS Apple Silicon
# Dubbelklik op dit bestand om de transcriptietool te starten.

# Resolve symlinks en ga naar de projectmap
SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || perl -e 'use Cwd "abs_path"; print abs_path(shift)' "$0")"
PROJECT_DIR="$(dirname "$SCRIPT_PATH")"
cd "$PROJECT_DIR"

VENV_DIR="$PROJECT_DIR/venv"

echo ""
echo "============================================"
echo "  CML Transcriptie Tool - Setup"
echo "============================================"
echo ""

# 1. Check architectuur
ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ]; then
    echo "FOUT: Dit programma werkt alleen op Apple Silicon (M1/M2/M3/M4)."
    echo "Huidige architectuur: $ARCH"
    echo ""
    read -p "Druk op Enter om af te sluiten..."
    exit 1
fi
echo "[OK] Apple Silicon ($ARCH)"

# 2. Check Homebrew
if ! command -v brew &> /dev/null; then
    echo ""
    echo "FOUT: Homebrew is niet geinstalleerd."
    echo ""
    echo "Installeer Homebrew eerst met dit commando:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo ""
    echo "Meer info: https://brew.sh"
    echo ""
    read -p "Druk op Enter om af te sluiten..."
    exit 1
fi
echo "[OK] Homebrew gevonden"

# 3. Check/installeer ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo ""
    echo "ffmpeg niet gevonden, wordt geinstalleerd..."
    brew install ffmpeg
    if [ $? -ne 0 ]; then
        echo "FOUT: ffmpeg installatie mislukt."
        read -p "Druk op Enter om af te sluiten..."
        exit 1
    fi
fi
echo "[OK] ffmpeg gevonden"

# 4. Check/installeer Python 3
if ! command -v python3 &> /dev/null; then
    echo ""
    echo "Python 3 niet gevonden, wordt geinstalleerd via Homebrew..."
    brew install python@3.11
    if [ $? -ne 0 ]; then
        echo "FOUT: Python installatie mislukt."
        read -p "Druk op Enter om af te sluiten..."
        exit 1
    fi
fi
PYTHON_CMD="python3"
PYTHON_VERSION=$($PYTHON_CMD --version 2>&1)
echo "[OK] $PYTHON_VERSION"

# 5. Maak venv aan als die niet bestaat
if [ ! -d "$VENV_DIR" ]; then
    echo ""
    echo "Virtuele omgeving aanmaken..."
    $PYTHON_CMD -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo "FOUT: Kon virtuele omgeving niet aanmaken."
        read -p "Druk op Enter om af te sluiten..."
        exit 1
    fi
    echo "[OK] Virtuele omgeving aangemaakt"
fi

# 6. Activeer venv
source "$VENV_DIR/bin/activate"
echo "[OK] Virtuele omgeving geactiveerd"

# 7. Check/installeer dependencies
if ! python -c "import whisperx" 2>/dev/null; then
    echo ""
    echo "Afhankelijkheden installeren..."
    echo "(Dit kan enkele minuten duren bij eerste gebruik)"
    echo ""
    pip install --upgrade pip --quiet
    pip install -r "$PROJECT_DIR/requirements.txt"
    if [ $? -ne 0 ]; then
        echo ""
        echo "FOUT: Installatie van afhankelijkheden mislukt."
        read -p "Druk op Enter om af te sluiten..."
        exit 1
    fi
    echo ""
    echo "[OK] Alle afhankelijkheden geinstalleerd"
fi

# 8. Maak launcher in ~/Applications als die nog niet bestaat
APPS_DIR="$HOME/Applications"
LINK_PATH="$APPS_DIR/CML Transcriptie.command"
if [ ! -f "$LINK_PATH" ]; then
    mkdir -p "$APPS_DIR"
    printf '#!/bin/bash\nexec "%s/start.command"\n' "$PROJECT_DIR" > "$LINK_PATH"
    chmod +x "$LINK_PATH"
    echo "[OK] Snelkoppeling aangemaakt in ~/Applications/"
fi

echo ""
echo "============================================"
echo ""

# 9. Start de transcriptietool
python "$PROJECT_DIR/transcribe.py"

# 10. Houd terminal open
echo ""
read -p "Druk op Enter om af te sluiten..."
