#!/bin/bash

# Funktion zum Prüfen und Installieren von Paketen
check_and_install() {
    local package_name="$1"
    local package_command="${2:-$1}"
    local additional_packages="${3:-}"
    
    echo "Prüfe $package_name..."
    
    # Prüfen, ob das Paket installiert ist
    if ! command -v "$package_command" &> /dev/null; then
        echo "$package_name ist nicht installiert. Versuche zu installieren..."
        
        # Update Repository und Installation
        sudo apt update
        sudo apt install -y "$package_name" $additional_packages
        
        # Prüfen, ob die Installation erfolgreich war
        if ! command -v "$package_command" &> /dev/null; then
            echo "Installation von $package_name fehlgeschlagen."
            return 1
        else
            echo "$package_name wurde erfolgreich installiert."
        fi
    else
        echo "$package_name ist bereits installiert: $($package_command --version 2>&1 | head -n 1)"
    fi
    
    return 0
}

# Hauptteil des Scripts
echo "Prüfe Systemabhängigkeiten..."

# Prüfe und installiere Python3
check_and_install python3 python3 "python3-venv python3-pip" || exit 1

# Prüfe und installiere weitere Abhängigkeiten
check_and_install git || exit 1
check_and_install curl || exit 1

# Node.js als Beispiel für einen Befehl, der anders heißt als das Paket
check_and_install nodejs node "npm" || exit 1

echo "Alle benötigten Abhängigkeiten sind installiert."