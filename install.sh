SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR" && pwd )"

# Import methods
source "$PROJECT_ROOT/installer/python_tool.sh"

# Run Checks

"$PROJECT_ROOT/pre/checks.sh"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script has to be run with root privileges."
  exit 1
fi


install_python_tool "arsenal" "arsenal_venv" "https://github.com/Orange-Cyberdefense/arsenal.git"

