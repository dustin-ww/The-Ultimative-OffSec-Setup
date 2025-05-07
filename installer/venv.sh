#!/bin/bash

# Funktion zur Prüfung der Voraussetzungen
check_prerequisites() {
    # Prüfen, ob Python installiert ist
    if ! command -v python3 &> /dev/null; then
        echo "Python 3 ist nicht installiert. Bitte installiere Python 3."
        return 1
    fi
    
    # Prüfen, ob venv-Modul verfügbar ist
    python3 -m venv --help &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Python venv-Modul ist nicht verfügbar. Installiere es mit 'sudo apt install python3-venv' (für Ubuntu/Debian)."
        return 1
    fi
    
    return 0
}

# Funktion zur Erstellung eines virtuellen Environments
create_venv() {
    local venv_name="$1"
    local base_path="${2:-$HOME/venvs}"
    local venv_path="$base_path/$venv_name"
    
    echo "Erstelle Virtual Environment '$venv_name' in $venv_path..."
    
    # Verzeichnis erstellen, falls es nicht existiert
    mkdir -p "$base_path"
    
    # Virtual Environment erstellen
    python3 -m venv "$venv_path"
    
    return $?
}

# Funktion zum Hinzufügen eines venv zum PATH
add_venv_to_path() {
    local venv_name="$1"
    local venv_path="$2"
    
    # Shell-Konfigurationsdatei finden
    local shell_config=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    else
        echo "Weder .bashrc noch .zshrc gefunden. Bitte füge den PATH manuell hinzu."
        return 1
    fi
    
    # Prüfen, ob der Pfad bereits in der Konfigurationsdatei existiert
    if grep -q "$venv_path/bin" "$shell_config"; then
        echo "PATH-Eintrag für '$venv_name' existiert bereits in $shell_config."
    else
        echo "Füge PATH-Eintrag für '$venv_name' zu $shell_config hinzu..."
        echo "" >> "$shell_config"
        echo "# Virtual Environment $venv_name zum PATH hinzufügen" >> "$shell_config"
        echo "export PATH=\"$venv_path/bin:\$PATH\"" >> "$shell_config"
    fi
    
    return 0
}

# Funktion zur Ausgabe von Nutzungshinweisen
print_usage_info() {
    local venv_name="$1"
    local venv_path="$2"
    local shell_config="$3"
    
    echo "Virtual Environment '$venv_name' wurde erfolgreich erstellt."
    echo "Bitte führe 'source $shell_config' aus, um die Änderungen zu übernehmen."
    echo "Oder starte eine neue Terminal-Session."
    echo ""
    echo "Aktiviere das venv mit: source $venv_path/bin/activate"
}

# Hauptfunktion zur Erstellung eines venv
setup_venv() {
    local venv_name="$1"
    local base_path="${2:-$HOME/venvs}"
    local venv_path="$base_path/$venv_name"
    
    # Voraussetzungen prüfen
    check_prerequisites || return 1
    
    # Virtual Environment erstellen
    create_venv "$venv_name" "$base_path" || {
        echo "Fehler beim Erstellen des Virtual Environments."
        return 1
    }
    
    # Shell-Konfigurationsdatei finden
    local shell_config=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    else
        echo "Weder .bashrc noch .zshrc gefunden. Bitte füge den PATH manuell hinzu."
        return 1
    fi
    
    # Zum PATH hinzufügen
    add_venv_to_path "$venv_name" "$venv_path" || return 1
    
    # Nutzungshinweise ausgeben
    print_usage_info "$venv_name" "$venv_path" "$shell_config"
    
    return 0
}

# Hier beginnt die Script-Ausführung, wenn kein Parameter übergeben wurde
if [ $# -eq 0 ]; then
    echo "Verwendung: $0 <venv_name> [base_path]"
    echo "Beispiel: $0 mein_projekt ~/python_envs"
    exit 1
fi

# venv anlegen mit den übergebenen Parametern
setup_venv "$@"