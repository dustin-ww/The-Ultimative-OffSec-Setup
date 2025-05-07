bash#!/bin/bash
set -e

install_python_tool() {
    local tool_name="$1"
    local venv_name="${2:-${tool_name}_venv}"
    local repo_url="$3"
    
    echo "Installing $tool_name..."
    
    # Erstelle Verzeichnisse
    mkdir -p /opt/tools/$tool_name
    mkdir -p /opt/venvs
    
    # Prüfe/Installiere Abhängigkeiten
    apt-get update
    apt-get install -y python3 python3-venv python3-pip git
    
    # Klone Repository
    git clone "$repo_url" /opt/tools/$tool_name
    
    # Erstelle venv
    python3 -m venv /opt/venvs/$venv_name
    
    # Aktiviere venv und installiere Abhängigkeiten
    source /opt/venvs/$venv_name/bin/activate
    pip install -r /opt/tools/$tool_name/requirements.txt
    
    # Erstelle Symlink für einfachen Zugriff
    ln -sf /opt/tools/$tool_name/run /usr/local/bin/$tool_name
    
    # Erstelle Wrapper-Script
    cat > /usr/local/bin/$tool_name <<EOF
#!/bin/bash
source /opt/venvs/$venv_name/bin/activate
cd /opt/tools/$tool_name
./run "\$@"
EOF
    chmod +x /usr/local/bin/$tool_name
    
    echo "$tool_name Installation abgeschlossen."
}
