#!/bin/bash

# CozyUI Installation Script
# This script installs CozyUI with all its features and enhancements
# Version: 2.0.0

# Color codes for pretty output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# ASCII Art Logo
echo -e "${CYAN}"
cat << "EOF"
█████████                                 █████  █████ █████
███░░░░░███                               ░░███  ░░███ ░░███
███     ░░░   ██████   █████████ █████ ████ ░███   ░███  ░███
░███          ███░░███ ░█░░░░███ ░░███ ░███  ░███   ░███  ░███
░███         ░███ ░███ ░   ███░   ░███ ░███  ░███   ░███  ░███
░░███     ███░███ ░███   ███░   █ ░███ ░███  ░███   ░███  ░███
░░█████████ ░░██████   █████████ ░░███████  ░░████████   █████
░░░░░░░░░   ░░░░░░   ░░░░░░░░░   ░░░░░███   ░░░░░░░░   ░░░░░
                                    ███ ░███                    
                                   ░░██████
EOF
echo -e "${RESET}"

echo -e "${BOLD}${BLUE}Welcome to CozyUI Terminal Installation${RESET}"
echo -e "${CYAN}Enhance your productivity and enjoy your terminal time${RESET}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display progress
display_progress() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to display a step
display_step() {
    echo -e "\n${BOLD}${BLUE}[*] $1${RESET}"
}

# Function to display success
display_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

# Function to display error and exit
display_error() {
    echo -e "${RED}✗ Error: $1${RESET}"
    exit 1
}

# Function to display warning
display_warning() {
    echo -e "${YELLOW}! Warning: $1${RESET}"
}

# Function to display info
display_info() {
    echo -e "${CYAN}i $1${RESET}"
}

# Function to get user's shell
get_shell() {
    if [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$FISH_VERSION" ]; then
        echo "fish"
    else
        echo $(basename "$SHELL")
    fi
}

# Function to get shell config file path
get_shell_config() {
    local shell_name=$(get_shell)
    local config_file=""
    
    case "$shell_name" in
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                config_file="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                config_file="$HOME/.bash_profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            mkdir -p "$HOME/.config/fish"
            ;;
        *)
            display_warning "Unsupported shell: $shell_name. Using .bashrc as fallback."
            config_file="$HOME/.bashrc"
            ;;
    esac
    
    echo "$config_file"
}

# Check system requirements
display_step "Checking system requirements"

# Check if curl or wget is installed
if command_exists curl; then
    DOWNLOADER="curl -fsSL"
    display_success "curl found"
elif command_exists wget; then
    DOWNLOADER="wget -qO-"
    display_success "wget found"
else
    display_error "Neither curl nor wget found. Please install one of them and try again."
fi

# Check if git is installed
if command_exists git; then
    display_success "git found"
else
    display_warning "git not found. Installing git..."
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -y git
    elif command_exists yum; then
        sudo yum install -y git
    elif command_exists brew; then
        brew install git
    elif command_exists pacman; then
        sudo pacman -S --noconfirm git
    else
        display_error "Could not install git. Please install git manually and try again."
    fi
    
    if command_exists git; then
        display_success "git installed successfully"
    else
        display_error "Failed to install git. Please install git manually and try again."
    fi
fi

# Create installation directory
COZYUI_DIR="$HOME/.cozyui"
display_step "Creating installation directory at $COZYUI_DIR"

if [ -d "$COZYUI_DIR" ]; then
    display_warning "CozyUI directory already exists. Backing up..."
    mv "$COZYUI_DIR" "${COZYUI_DIR}.backup.$(date +%s)"
    display_success "Backup created"
fi

mkdir -p "$COZYUI_DIR"
display_success "Installation directory created"

# Create subdirectories
mkdir -p "$COZYUI_DIR/themes"
mkdir -p "$COZYUI_DIR/plugins"
mkdir -p "$COZYUI_DIR/config"
mkdir -p "$COZYUI_DIR/bin"
mkdir -p "$COZYUI_DIR/cache"

# Download core files
display_step "Downloading CozyUI core files"

# In a real scenario, these would be downloaded from a server
# For this demo, we'll create them locally

# Create main script
cat > "$COZYUI_DIR/bin/cozyui.sh" << 'EOL'
#!/bin/bash

# CozyUI main script
COZYUI_DIR="$HOME/.cozyui"
CONFIG_FILE="$COZYUI_DIR/config/config.sh"

# Source configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Function to show help
show_help() {
    echo -e "\033[1;36mCozyUI Terminal\033[0m - Enhance your terminal experience"
    echo ""
    echo -e "\033[1;33mUsage:\033[0m cozyui [command] [options]"
    echo ""
    echo -e "\033[1;33mCore Commands:\033[0m"
    echo -e "  \033[1;32mtheme\033[0m [name|list]       Set or list themes"
    echo -e "  \033[1;32mplugin\033[0m [action] [name] Manage plugins"
    echo -e "  \033[1;32mconfig\033[0m                 Open configuration"
    echo -e "  \033[1;32mupdate\033[0m                 Check for updates"
    echo -e "  \033[1;32mstatus\033[0m                 Show CozyUI status"
    echo -e "  \033[1;32mhelp\033[0m [command]         Show help for specific command"
    echo ""
    echo -e "\033[1;33mUtility Commands:\033[0m"
    echo -e "  \033[1;32msearch\033[0m                 Search command history"
    echo -e "  \033[1;32mvisual\033[0m                 Toggle visual data mode"
    echo -e "  \033[1;32mbackup\033[0m                 Backup your configuration"
    echo -e "  \033[1;32mrestore\033[0m                Restore from backup"
    echo ""
    echo -e "\033[1;33mExamples:\033[0m"
    echo -e "  cozyui theme list        List available themes"
    echo -e "  cozyui theme dracula     Apply Dracula theme"
    echo -e "  cozyui plugin list       List available plugins"
    echo -e "  cozyui plugin install git-enhancer   Install Git Enhancer plugin"
    echo -e "  cozyui help theme        Show detailed help for theme command"
    
    # If a specific command is provided, show detailed help
    if [ -n "$1" ]; then
        echo ""
        case "$1" in
            theme)
                echo -e "\033[1;33mTheme Command:\033[0m"
                echo -e "  \033[1;32mcozyui theme list\033[0m              List all available themes"
                echo -e "  \033[1;32mcozyui theme <name>\033[0m            Apply the specified theme"
                echo -e "  \033[1;32mcozyui theme preview <name>\033[0m    Preview a theme without applying it"
                echo -e "  \033[1;32mcozyui theme create <name>\033[0m     Create a new custom theme"
                ;;
            plugin)
                echo -e "\033[1;33mPlugin Command:\033[0m"
                echo -e "  \033[1;32mcozyui plugin list\033[0m             List all installed plugins"
                echo -e "  \033[1;32mcozyui plugin install <name>\033[0m   Install a plugin"
                echo -e "  \033[1;32mcozyui plugin remove <name>\033[0m    Remove a plugin"
                echo -e "  \033[1;32mcozyui plugin info <name>\033[0m      Show information about a plugin"
                echo -e "  \033[1;32mcozyui plugin enable <name>\033[0m    Enable a plugin"
                echo -e "  \033[1;32mcozyui plugin disable <name>\033[0m   Disable a plugin"
                ;;
            config)
                echo -e "\033[1;33mConfig Command:\033[0m"
                echo -e "  \033[1;32mcozyui config\033[0m                  Open configuration file in editor"
                echo -e "  \033[1;32mcozyui config show\033[0m             Display current configuration"
                echo -e "  \033[1;32mcozyui config set <key> <value>\033[0m Set a configuration value"
                echo -e "  \033[1;32mcozyui config reset\033[0m            Reset to default configuration"
                ;;
            visual)
                echo -e "\033[1;33mVisual Command:\033[0m"
                echo -e "  \033[1;32mcozyui visual\033[0m                  Toggle visual mode on/off"
                echo -e "  \033[1;32mcozyui visual filesize <file>\033[0m  Display file size visually"
                echo -e "  \033[1;32mcozyui visual tree [dir] [depth]\033[0m Display directory tree"
                echo -e "  \033[1;32mcozyui visual output <command>\033[0m Display command output visually"
                ;;
            *)
                echo -e "No detailed help available for '$1'. Run 'cozyui help' for general help."
                ;;
        esac
    fi
}
}

# Function to manage themes
manage_themes() {
    case "$1" in
        list)
            echo -e "\033[1;36mAvailable themes:\033[0m"
            for theme in $(ls -1 "$COZYUI_DIR/themes" | sed 's/\.theme$//' | sort); do
                # Get theme description from first line of theme file
                local desc=$(head -n 1 "$COZYUI_DIR/themes/${theme}.theme" | sed 's/^# //')
                
                # Check if this is the current theme
                if [ "$theme" = "$(grep COZYUI_THEME "$COZYUI_DIR/config/theme_config" 2>/dev/null | cut -d= -f2)" ]; then
                    echo -e "  • \033[1;32m${theme}\033[0m \033[1;90m[active]\033[0m \033[0;37m${desc}\033[0m"
                else
                    echo -e "  • \033[1;34m${theme}\033[0m \033[0;37m${desc}\033[0m"
                fi
            done
            echo ""
            echo -e "Use \"cozyui theme <name>\" to apply a theme"
            ;;
        preview)
            if [ -z "$2" ]; then
                echo -e "\033[1;31mError:\033[0m Please specify a theme to preview"
                echo "Usage: cozyui theme preview <name>"
                return 1
            fi
            
            if [ -f "$COZYUI_DIR/themes/$2.theme" ]; then
                echo -e "\033[1;36mPreviewing theme:\033[0m $2"
                echo ""
                
                # Display color samples
                source "$COZYUI_DIR/themes/$2.theme"
                echo -e "\033[48;2;${background//\#/};38;2;${foreground//\#/}m  Text Sample  \033[0m Background"
                echo -e "\033[38;2;${color1//\#/}m■\033[0m \033[38;2;${color2//\#/}m■\033[0m \033[38;2;${color3//\#/}m■\033[0m \033[38;2;${color4//\#/}m■\033[0m \033[38;2;${color5//\#/}m■\033[0m \033[38;2;${color6//\#/}m■\033[0m \033[38;2;${color7//\#/}m■\033[0m Primary Colors"
                echo -e "\033[38;2;${color8//\#/}m■\033[0m \033[38;2;${color9//\#/}m■\033[0m \033[38;2;${color10//\#/}m■\033[0m \033[38;2;${color11//\#/}m■\033[0m \033[38;2;${color12//\#/}m■\033[0m \033[38;2;${color13//\#/}m■\033[0m \033[38;2;${color14//\#/}m■\033[0m \033[38;2;${color15//\#/}m■\033[0m Secondary Colors"
                echo ""
                echo -e "To apply this theme, run: cozyui theme $2"
            else
                echo -e "\033[1;31mError:\033[0m Theme not found: $2"
                echo "Available themes:"
                ls -1 "$COZYUI_DIR/themes" | sed 's/\.theme$//' | sort
            fi
            ;;
        create)
            if [ -z "$2" ]; then
                echo -e "\033[1;31mError:\033[0m Please specify a name for the new theme"
                echo "Usage: cozyui theme create <name>"
                return 1
            fi
            
            if [ -f "$COZYUI_DIR/themes/$2.theme" ]; then
                echo -e "\033[1;31mError:\033[0m Theme already exists: $2"
                echo "Please choose a different name or remove the existing theme first."
                return 1
            fi
            
            echo -e "\033[1;36mCreating new theme:\033[0m $2"
            
            # Create a new theme based on default
            cp "$COZYUI_DIR/themes/dracula.theme" "$COZYUI_DIR/themes/$2.theme"
            
            # Open in editor
            if command -v "$EDITOR" >/dev/null 2>&1; then
                "$EDITOR" "$COZYUI_DIR/themes/$2.theme"
            elif command -v nano >/dev/null 2>&1; then
                nano "$COZYUI_DIR/themes/$2.theme"
            elif command -v vim >/dev/null 2>&1; then
                vim "$COZYUI_DIR/themes/$2.theme"
            else
                echo "No suitable editor found. Please edit $COZYUI_DIR/themes/$2.theme manually."
            fi
            
            echo -e "\033[1;32mTheme created:\033[0m $2"
            echo "To apply this theme, run: cozyui theme $2"
            ;;
        *)
            if [ -f "$COZYUI_DIR/themes/$1.theme" ]; then
                echo -e "\033[1;36mApplying theme:\033[0m $1"
                cp "$COZYUI_DIR/themes/$1.theme" "$COZYUI_DIR/config/current_theme"
                echo "COZYUI_THEME=$1" > "$COZYUI_DIR/config/theme_config"
                echo -e "\033[1;32mTheme applied successfully!\033[0m"
                echo "Please restart your terminal or run 'source $(get_shell_config)' to see changes."
            else
                echo -e "\033[1;31mError:\033[0m Theme not found: $1"
                echo ""
                echo -e "\033[1;36mAvailable themes:\033[0m"
                ls -1 "$COZYUI_DIR/themes" | sed 's/\.theme$//' | sort | sed 's/^/  • /'
            fi
            ;;
    esac
}

# Function to manage plugins
manage_plugins() {
    case "$1" in
        list)
            echo -e "\033[1;36mInstalled plugins:\033[0m"
            if [ -z "$(ls -A "$COZYUI_DIR/plugins" 2>/dev/null)" ]; then
                echo -e "  No plugins installed"
                echo ""
                echo -e "To install a plugin, run: cozyui plugin install <name>"
                return 0
            fi
            
            for plugin in $(ls -1 "$COZYUI_DIR/plugins" | sort); do
                # Check if plugin is enabled
                if [ -f "$COZYUI_DIR/plugins/$plugin/disabled" ]; then
                    echo -e "  • \033[1;90m${plugin}\033[0m \033[1;31m[disabled]\033[0m"
                else
                    echo -e "  • \033[1;32m${plugin}\033[0m \033[1;90m[enabled]\033[0m"
                fi
            done
            echo ""
            echo -e "Use \"cozyui plugin info <name>\" to see plugin details"
            ;;
        install)
            if [ -z "$2" ]; then
                echo -e "\033[1;31mError:\033[0m Please specify a plugin to install"
                echo "Usage: cozyui plugin install <name>"
                return 1
            fi
            echo -e "\033[1;36mInstalling plugin:\033[0m $2"
            
            # In a real scenario, this would download and install the plugin
            if [ -d "$COZYUI_DIR/plugins/$2" ]; then
                echo -e "\033[1;33mPlugin already installed:\033[0m $2"
                echo "To reinstall, remove it first with: cozyui plugin remove $2"
                return 1
            fi
            
            mkdir -p "$COZYUI_DIR/plugins/$2"
            echo -e "\033[1;32mPlugin installed successfully:\033[0m $2"
            echo "Restart your terminal or run 'source $(get_shell_config)' to activate the plugin"
            ;;
        remove)
            if [ -z "$2" ]; then
                echo -e "\033[1;31mError:\033[0m Please specify a plugin to remove"
                echo "Usage: cozyui plugin remove <name>"
                return 1
            fi
            if [ -d "$COZYUI_DIR/plugins/$2" ]; then
                echo -e "\033[1;36mRemoving plugin:\033[0m $2"
                rm -rf "$COZYUI_DIR/plugins/$2"
                echo -e "\033[1;32mPlugin removed successfully:\033[0m $2"
                echo "Restart your terminal or run 'source $(get_shell_config)' to apply changes"
            else
                echo -e "\033[1;31mError:\033[0m Plugin not found: $2"
                echo "Available plugins:"
                ls -1 "$COZYUI_DIR/plugins" 2>/dev/null || echo "  No plugins installed"
            fi
            ;;
        info)
            if [ -z "$2" ]; then
                echo -e "\033[1;31mError:\033[0m Please specify a plugin to show info for"
                echo "Usage: cozyui plugin info <name>"
                return 1
            fi
            if [ -d "$COZYUI_DIR/plugins/$2" ]; then
                echo -e "\033[1;36mPlugin information:\033[0m $2"
                
                # Check if plugin is enabled
                if [ -f "$COZYUI_DIR/plugins/$2/disabled" ]; then
                    echo -e "\033[1;33mStatus:\033[0m Disabled"
                else
                    echo -e "\033[1;32mStatus:\033[0m Enabled"
                fi
                
                # List plugin files
                echo -e "\033[1;34mFiles:\033[0m"
                find "$COZYUI_DIR/plugins/$2" -type f -name "*.sh" | while read file; do
                    echo "  $(basename "$file")"
                done
                
                # Show plugin description if available
                if [ -f "$COZYUI_DIR/plugins/$2/README" ]; then
                    echo -e "\033[1;34mDescription:\033[0m"
                    cat "$COZYUI_DIR/plugins/$2/README"
                fi
                
                # Show available commands
                echo -e "\033[1;34mCommands:\033[0m"
                grep -h "^alias" "$COZYUI_DIR/plugins/$2"/*.sh 2>/dev/null | sed 's/alias \([^=]*\)=.*/  \1/' || echo "  No commands found"
            else
                echo -e "\033[1;31mError:\033[0m Plugin not found: $2"
                echo "Available plugins:"
                ls -1 "$COZYUI_DIR/plugins" 2>/dev/null || echo "  No plugins installed"
            fi
            ;;
        enable)
            if [ -z "$2" ]; then
                echo -e "\033[1;31mError:\033[0m Please specify a plugin to enable"
                echo "Usage: cozyui plugin enable <name>"
                return 1
            fi
            if [ -d "$COZYUI_DIR/plugins/$2" ]; then
                if [ -f "$COZYUI_DIR/plugins/$2/disabled" ]; then
                    rm -f "$COZYUI_DIR/plugins/$2/disabled"
                    echo -e "\033[1;32mPlugin enabled:\033[0m $2"
                    echo "Restart your terminal or run 'source $(get_shell_config)' to apply changes"
                else
                    echo -e "\033[1;33mPlugin already enabled:\033[0m $2"
                fi
            else
                echo -e "\033[1;31mError:\033[0m Plugin not found: $2"
                echo "Available plugins:"
                ls -1 "$COZYUI_DIR/plugins" 2>/dev/null || echo "  No plugins installed"
            fi
            ;;
        disable)
            if [ -z "$2" ]; then
                echo -e "\033[1;31mError:\033[0m Please specify a plugin to disable"
                echo "Usage: cozyui plugin disable <name>"
                return 1
            fi
            if [ -d "$COZYUI_DIR/plugins/$2" ]; then
                touch "$COZYUI_DIR/plugins/$2/disabled"
                echo -e "\033[1;32mPlugin disabled:\033[0m $2"
                echo "Restart your terminal or run 'source $(get_shell_config)' to apply changes"
            else
                echo -e "\033[1;31mError:\033[0m Plugin not found: $2"
                echo "Available plugins:"
                ls -1 "$COZYUI_DIR/plugins" 2>/dev/null || echo "  No plugins installed"
            fi
            ;;
        *)
            echo -e "\033[1;31mError:\033[0m Unknown plugin command: $1"
            echo -e "\033[1;36mAvailable commands:\033[0m"
            echo "  list                List installed plugins"
            echo "  install <name>      Install a plugin"
            echo "  remove <name>       Remove a plugin"
            echo "  info <name>         Show plugin information"
            echo "  enable <name>       Enable a plugin"
            echo "  disable <name>      Disable a plugin"
            ;;
    esac
}

# Function to search command history
search_history() {
    if command -v fzf >/dev/null 2>&1; then
        history | fzf --ansi --no-sort --tac --tiebreak=index | sed 's/^\s*[0-9]\+\s\+//g'
    else
        echo "Enhanced search requires fzf. Installing..."
        if command -v brew >/dev/null 2>&1; then
            brew install fzf
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y fzf
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y fzf
        else
            echo "Could not install fzf. Please install it manually."
            return 1
        fi
        echo "fzf installed. Please try again."
    fi
}

# Function to toggle visual data mode
toggle_visual_mode() {
    if [ "$COZYUI_VISUAL_MODE" = "enabled" ]; then
        echo "Disabling visual data mode"
        sed -i 's/COZYUI_VISUAL_MODE="enabled"/COZYUI_VISUAL_MODE="disabled"/g' "$CONFIG_FILE"
        echo "Visual data mode disabled"
    else
        echo "Enabling visual data mode"
        sed -i 's/COZYUI_VISUAL_MODE="disabled"/COZYUI_VISUAL_MODE="enabled"/g' "$CONFIG_FILE"
        echo "Visual data mode enabled"
    fi
}

# Main command handler
case "$1" in
    theme)
        shift
        manage_themes "$@"
        ;;
    plugin)
        shift
        manage_plugins "$@"
        ;;
    config)
        if command -v "$EDITOR" >/dev/null 2>&1; then
            "$EDITOR" "$CONFIG_FILE"
        elif command -v nano >/dev/null 2>&1; then
            nano "$CONFIG_FILE"
        elif command -v vim >/dev/null 2>&1; then
            vim "$CONFIG_FILE"
        else
            echo "No suitable editor found. Please edit $CONFIG_FILE manually."
        fi
        ;;
    update)
        echo "Checking for updates..."
        echo "CozyUI is up to date!"
        ;;
    status)
        echo "CozyUI Status:"
        echo "  Version: 1.0.0"
        echo "  Theme: $(grep COZYUI_THEME "$COZYUI_DIR/config/theme_config" | cut -d= -f2)"
        echo "  Visual Mode: $COZYUI_VISUAL_MODE"
        echo "  Plugins: $(ls -1 "$COZYUI_DIR/plugins" | wc -l)"
        ;;
    search)
        search_history
        ;;
    visual)
        toggle_visual_mode
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
        else
            echo "Unknown command: $1"
            echo "Run 'cozyui help' for usage information."
        fi
        ;;
esac
EOL

chmod +x "$COZYUI_DIR/bin/cozyui.sh"

# Create configuration file
cat > "$COZYUI_DIR/config/config.sh" << 'EOL'
# CozyUI Configuration

# Theme settings
COZYUI_THEME="dracula"

# Visual mode (enabled/disabled)
COZYUI_VISUAL_MODE="enabled"

# Smart prompt settings
COZYUI_PROMPT_GIT="enabled"
COZYUI_PROMPT_VENV="enabled"
COZYUI_PROMPT_TIME="enabled"

# Keyboard shortcuts
COZYUI_SHORTCUTS="enabled"

# Plugin settings
COZYUI_PLUGINS_AUTOLOAD="enabled"

# Performance settings
COZYUI_PERFORMANCE_MODE="optimized"

# Cross-platform compatibility
COZYUI_CROSS_PLATFORM="enabled"

# Auto-update settings
COZYUI_AUTO_UPDATE="enabled"
COZYUI_UPDATE_FREQUENCY="weekly"
EOL

# Create prompt customization file
cat > "$COZYUI_DIR/config/prompt.sh" << 'EOL'
# CozyUI Prompt Configuration

# Function to get git branch and status
cozyui_git_info() {
    if [ "$COZYUI_PROMPT_GIT" != "enabled" ]; then
        return
    fi
    
    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)
        local git_status=$(git status --porcelain 2>/dev/null)
        
        if [ -n "$git_status" ]; then
            echo " ($branch*)"
        else
            echo " ($branch)"
        fi
    fi
}

# Function to get virtual environment info
cozyui_venv_info() {
    if [ "$COZYUI_PROMPT_VENV" != "enabled" ]; then
        return
    fi
    
    if [ -n "$VIRTUAL_ENV" ]; then
        echo " ($(basename "$VIRTUAL_ENV"))"
    fi
}

# Function to show command execution time
cozyui_cmd_time() {
    if [ "$COZYUI_PROMPT_TIME" != "enabled" ]; then
        return
    fi
    
    if [ -n "$COZYUI_CMD_START_TIME" ]; then
        local end_time=$(date +%s)
        local elapsed=$((end_time - COZYUI_CMD_START_TIME))
        
        if [ $elapsed -gt 1 ]; then
            echo " [${elapsed}s]"
        fi
        unset COZYUI_CMD_START_TIME
    fi
}

# Function to set command start time
cozyui_cmd_start() {
    COZYUI_CMD_START_TIME=$(date +%s)
}

# Function to generate the prompt
cozyui_prompt() {
    local exit_code=$?
    local prompt_symbol="$"
    
    if [ $exit_code -ne 0 ]; then
        local status_color="\033[0;31m" # Red for error
    else
        local status_color="\033[0;32m" # Green for success
    fi
    
    # Reset color
    local reset_color="\033[0m"
    
    # Username and hostname color
    local user_color="\033[0;36m" # Cyan
    
    # Directory color
    local dir_color="\033[0;34m" # Blue
    
    # Git info color
    local git_color="\033[0;35m" # Magenta
    
    # Virtual env color
    local venv_color="\033[0;33m" # Yellow
    
    # Time color
    local time_color="\033[0;90m" # Gray
    
    # Build the prompt
    PS1="${status_color}❯${reset_color} ${user_color}\u@\h${reset_color}:${dir_color}\w${reset_color}${git_color}$(cozyui_git_info)${reset_color}${venv_color}$(cozyui_venv_info)${reset_color}${time_color}$(cozyui_cmd_time)${reset_color}\n${prompt_symbol} "
}

# Set up pre-command hook to track command execution time
if [ -n "$BASH_VERSION" ]; then
    # For Bash
    PROMPT_COMMAND="cozyui_cmd_start; cozyui_prompt"
    PS1="\$ "
    
    # Trap DEBUG signal to set command start time
    trap 'cozyui_cmd_start' DEBUG
elif [ -n "$ZSH_VERSION" ]; then
    # For Zsh
    precmd() {
        cozyui_prompt
    }
    
    preexec() {
        cozyui_cmd_start
    }
fi
EOL

# Create keyboard shortcuts file
cat > "$COZYUI_DIR/config/shortcuts.sh" << 'EOL'
# CozyUI Keyboard Shortcuts

if [ "$COZYUI_SHORTCUTS" != "enabled" ]; then
    return
fi

# For Bash
if [ -n "$BASH_VERSION" ]; then
    # Enable vi mode
    set -o vi
    
    # Ctrl+R for history search using fzf if available
    if command -v fzf >/dev/null 2>&1; then
        bind -x '"C-r": "cozyui search"'
    fi
    
    # Alt+C to change directory with fzf
    if command -v fzf >/dev/null 2>&1; then
        bind -x '"ec": "cd $(find . -type d | fzf)"'
    fi
    
    # Ctrl+L for clear screen
    bind -x '"C-l": clear'
    
    # Ctrl+E to edit command in editor
    bind -x '"C-e": "$EDITOR /tmp/cozyui_cmd.sh; source /tmp/cozyui_cmd.sh; rm /tmp/cozyui_cmd.sh"'
    
    # Ctrl+G for git status
    bind -x '"C-g": "git status"'
    
    # Ctrl+B to show current branch
    bind -x '"C-b": "git branch"'
    
    # Ctrl+P for plugin management
    bind -x '"C-p": "cozyui plugin list"'
    
# For Zsh
elif [ -n "$ZSH_VERSION" ]; then
    # Enable vi mode
    bindkey -v
    
    # Ctrl+R for history search using fzf if available
    if command -v fzf >/dev/null 2>&1; then
        bindkey '^R' fzf-history-widget
    fi
    
    # Alt+C to change directory with fzf
    if command -v fzf >/dev/null 2>&1; then
        bindkey '^[c' fzf-cd-widget
    fi
    
    # Ctrl+L for clear screen
    bindkey '^L' clear-screen
    
    # Ctrl+E to edit command in editor
    autoload -U edit-command-line
    zle -N edit-command-line
    bindkey '^E' edit-command-line
    
    # Ctrl+G for git status
    git_status() { git status; zle reset-prompt; }
    zle -N git_status
    bindkey '^G' git_status
    
    # Ctrl+B to show current branch
    git_branch() { git branch; zle reset-prompt; }
    zle -N git_branch
    bindkey '^B' git_branch
    
    # Ctrl+P for plugin management
    plugin_list() { cozyui plugin list; zle reset-prompt; }
    zle -N plugin_list
    bindkey '^P' plugin_list
fi
EOL

# Create visual data representation file
cat > "$COZYUI_DIR/bin/cozyui-visual.sh" << 'EOL'
#!/bin/bash

# CozyUI Visual Data Representation

if [ "$COZYUI_VISUAL_MODE" != "enabled" ]; then
    exit 0
fi

# Function to display file sizes visually
visual_filesize() {
    if [ -z "$1" ]; then
        echo "Usage: visual_filesize <file>"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "File not found: $1"
        return 1
    fi
    
    local size=$(du -b "$1" | cut -f1)
    local name=$(basename "$1")
    local bars=$(($size / 1024))
    
    if [ $bars -eq 0 ]; then
        bars=1
    elif [ $bars -gt 50 ]; then
        bars=50
    fi
    
    printf "%-20s " "$name"
    printf "[%${bars}s" | tr ' ' '█'
    printf "%s]" ""
    printf " %s\n" "$(du -h "$1" | cut -f1)"
}

# Function to display directory tree visually
visual_tree() {
    local dir="${1:-.}"
    local prefix=""
    local max_depth=${2:-2}
    
    visual_tree_recursive "$dir" "$prefix" 0 $max_depth
}

visual_tree_recursive() {
    local dir="$1"
    local prefix="$2"
    local depth=$3
    local max_depth=$4
    
    if [ $depth -gt $max_depth ]; then
        return
    fi
    
    local files=("$dir"/*)  
    local last_index=$((${#files[@]} - 1))
    
    for i in "${!files[@]}"; do
        local file="${files[$i]}"
        local name=$(basename "$file")
        
        if [ $i -eq $last_index ]; then
            echo -e "${prefix}└── $name"
            if [ -d "$file" ]; then
                visual_tree_recursive "$file" "${prefix}    " $((depth + 1)) $max_depth
            fi
        else
            echo -e "${prefix}├── $name"
            if [ -d "$file" ]; then
                visual_tree_recursive "$file" "${prefix}│   " $((depth + 1)) $max_depth
            fi
        fi
    done
}

# Function to display command output visually
visual_output() {
    if [ -z "$1" ]; then
        echo "Usage: visual_output <command>"
        return 1
    fi
    
    local output=$($@)
    local lines=$(echo "$output" | wc -l)
    
    echo -e "\033[1;34m┌─ Command: $@\033[0m"
    echo -e "\033[1;34m│\033[0m"
    echo "$output" | while IFS= read -r line; do
        echo -e "\033[1;34m│\033[0m $line"
    done
    echo -e "\033[1;34m└─ ($lines lines)\033[0m"
}

# Main command handler
case "$1" in
    filesize)
        shift
        visual_filesize "$@"
        ;;
    tree)
        shift
        visual_tree "$@"
        ;;
    output)
        shift
        visual_output "$@"
        ;;
    *)
        echo "CozyUI Visual Data Tools"
        echo ""
        echo "Usage: cozyui-visual <command> [options]"
        echo ""
        echo "Commands:"
        echo "  filesize <file>     Display file size visually"
        echo "  tree [dir] [depth]  Display directory tree"
        echo "  output <command>    Display command output visually"
        ;;
esac
EOL

chmod +x "$COZYUI_DIR/bin/cozyui-visual.sh"

# Create theme files
display_step "Creating theme files"

# Create Dracula theme
cat > "$COZYUI_DIR/themes/dracula.theme" << 'EOL'
# Dracula theme for CozyUI
background="#282a36"
foreground="#f8f8f2"
cursor="#f8f8f2"
selection_background="#454037"
selection_foreground="#f8f8f2"
color0="#282a36"
color1="#f92672"
color2="#a6e22e"
color3="#f4bf75"
color4="#66d9ef"
color5="#ae81ff"
color6="#a1efe4"
color7="#f8f8f2"
color8="#75715e"
color9="#f92672"
color10="#a6e22e"
color11="#f4bf75"
color12="#66d9ef"
color13="#ae81ff"
color14="#a1efe4"
color15="#f9f8f5"
EOL

# Create Monokai theme
cat > "$COZYUI_DIR/themes/monokai.theme" << 'EOL'
# Monokai theme for CozyUI
background="#272822"
foreground="#f8f8f2"
cursor="#f8f8f2"
selection_background="#49483e"
selection_foreground="#f8f8f2"
color0="#272822"
color1="#f92672"
color2="#a6e22e"
color3="#f4bf75"
color4="#66d9ef"
color5="#ae81ff"
color6="#a1efe4"
color7="#f8f8f2"
color8="#75715e"
color9="#f92672"
color10="#a6e22e"
color11="#f4bf75"
color12="#66d9ef"
color13="#ae81ff"
color14="#a1efe4"
color15="#f9f8f5"
EOL

# Create Solarized theme
cat > "$COZYUI_DIR/themes/solarized.theme" << 'EOL'
# Solarized theme for CozyUI
background="#002b36"
foreground="#839496"
cursor="#93a1a1"
selection_background="#073642"
selection_foreground="#93a1a1"
color0="#073642"
color1="#dc322f"
color2="#859900"
color3="#b58900"
color4="#268bd2"
color5="#d33682"
color6="#2aa198"
color7="#eee8d5"
color8="#002b36"
color9="#cb4b16"
color10="#586e75"
color11="#657b83"
color12="#839496"
color13="#6c71c4"
color14="#93a1a1"
color15="#fdf6e3"
EOL

# Create Tokyo Night theme
cat > "$COZYUI_DIR/themes/tokyo-night.theme" << 'EOL'
# Tokyo Night theme for CozyUI
background="#1a1b26"
foreground="#a9b1d6"
cursor="#a9b1d6"
selection_background="#33467c"
selection_foreground="#c0caf5"
color0="#1a1b26"
color1="#f7768e"
color2="#9ece6a"
color3="#e0af68"
color4="#7aa2f7"
color5="#bb9af7"
color6="#7dcfff"
color7="#a9b1d6"
color8="#414868"
color9="#f7768e"
color10="#9ece6a"
color11="#e0af68"
color12="#7aa2f7"
color13="#bb9af7"
color14="#7dcfff"
color15="#c0caf5"
EOL

# Create sample plugins
display_step "Creating sample plugins"

# Create Git Enhancer plugin
mkdir -p "$COZYUI_DIR/plugins/git-enhancer"
cat > "$COZYUI_DIR/plugins/git-enhancer/git-enhancer.sh" << 'EOL'
#!/bin/bash

# Git Enhancer plugin for CozyUI

# Enhanced git status command
git_status_enhanced() {
    echo -e "\033[1;34m=== Git Status Enhanced ===\033[0m"
    
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not a git repository"
        return 1
    fi
    
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)
    echo -e "\033[1;32mBranch:\033[0m $branch"
    
    local remote=$(git config --get branch.$branch.remote 2>/dev/null)
    if [ -n "$remote" ]; then
        local remote_branch=$(git config --get branch.$branch.merge | sed 's|refs/heads/||')
        local ahead=$(git rev-list --count $remote/$remote_branch..$branch 2>/dev/null)
        local behind=$(git rev-list --count $branch..$remote/$remote_branch 2>/dev/null)
        
        if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            echo -e "\033[1;33mStatus:\033[0m Diverged (ahead $ahead, behind $behind)"
        elif [ "$ahead" -gt 0 ]; then
            echo -e "\033[1;32mStatus:\033[0m Ahead by $ahead commit(s)"
        elif [ "$behind" -gt 0 ]; then
            echo -e "\033[1;31mStatus:\033[0m Behind by $behind commit(s)"
        else
            echo -e "\033[1;32mStatus:\033[0m Up to date"
        fi
    fi
    
    local staged=$(git diff --name-only --cached | wc -l)
    local unstaged=$(git diff --name-only | wc -l)
    local untracked=$(git ls-files --others --exclude-standard | wc -l)
    
    echo -e "\033[1;36mChanges:\033[0m"
    echo -e "  \033[1;32mStaged:\033[0m $staged"
    echo -e "  \033[1;33mUnstaged:\033[0m $unstaged"
    echo -e "  \033[1;31mUntracked:\033[0m $untracked"
    
    if [ $staged -gt 0 ]; then
        echo -e "\n\033[1;32mStaged changes:\033[0m"
        git diff --name-status --cached | while read status file; do
            case $status in
                M) echo -e "  \033[1;33mModified:\033[0m $file" ;;
                A) echo -e "  \033[1;32mAdded:\033[0m $file" ;;
                D) echo -e "  \033[1;31mDeleted:\033[0m $file" ;;
                R) echo -e "  \033[1;35mRenamed:\033[0m $file" ;;
                C) echo -e "  \033[1;36mCopied:\033[0m $file" ;;
                *) echo -e "  \033[1;37mUnknown ($status):\033[0m $file" ;;
            esac
        done
    fi
    
    if [ $unstaged -gt 0 ]; then
        echo -e "\n\033[1;33mUnstaged changes:\033[0m"
        git diff --name-status | while read status file; do
            case $status in
                M) echo -e "  \033[1;33mModified:\033[0m $file" ;;
                A) echo -e "  \033[1;32mAdded:\033[0m $file" ;;
                D) echo -e "  \033[1;31mDeleted:\033[0m $file" ;;
                R) echo -e "  \033[1;35mRenamed:\033[0m $file" ;;
                C) echo -e "  \033[1;36mCopied:\033[0m $file" ;;
                *) echo -e "  \033[1;37mUnknown ($status):\033[0m $file" ;;
            esac
        done
    fi
    
    if [ $untracked -gt 0 ]; then
        echo -e "\n\033[1;31mUntracked files:\033[0m"
        git ls-files --others --exclude-standard | while read file; do
            echo -e "  $file"
        done
    fi
}

# Enhanced git log command
git_log_enhanced() {
    echo -e "\033[1;34m=== Git Log Enhanced ===\033[0m"
    
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not a git repository"
        return 1
    fi
    
    local count=${1:-5}
    
    git log -n $count --pretty=format:"%C(yellow)%h%Creset %C(green)%ad%Creset %C(blue)%an%Creset %C(red)%d%Creset %s" --date=short
}

# Register commands
alias gits="git_status_enhanced"
alias gitl="git_log_enhanced"
EOL

# Create System Monitor plugin
mkdir -p "$COZYUI_DIR/plugins/system-monitor"
cat > "$COZYUI_DIR/plugins/system-monitor/system-monitor.sh" << 'EOL'
#!/bin/bash

# System Monitor plugin for CozyUI

# Function to display system information
system_info() {
    echo -e "\033[1;34m=== System Information ===\033[0m"
    
    # OS information
    echo -e "\033[1;32mOS:\033[0m $(uname -s)"
    echo -e "\033[1;32mKernel:\033[0m $(uname -r)"
    
    # CPU information
    if command -v lscpu >/dev/null 2>&1; then
        echo -e "\033[1;32mCPU:\033[0m $(lscpu | grep 'Model name' | sed 's/Model name: *//g')"
        echo -e "\033[1;32mCPU Cores:\033[0m $(lscpu | grep '^CPU(s)' | awk '{print $2}')"
    elif [ -f "/proc/cpuinfo" ]; then
        echo -e "\033[1;32mCPU:\033[0m $(grep 'model name' /proc/cpuinfo | head -1 | sed 's/model name.*: //g')"
        echo -e "\033[1;32mCPU Cores:\033[0m $(grep -c '^processor' /proc/cpuinfo)"
    elif command -v sysctl >/dev/null 2>&1; then
        echo -e "\033[1;32mCPU:\033[0m $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")"
        echo -e "\033[1;32mCPU Cores:\033[0m $(sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")"
    else
        echo -e "\033[1;32mCPU:\033[0m Unknown"
    fi
    
    # Memory information
    if command -v free >/dev/null 2>&1; then
        local mem_total=$(free -h | awk '/^Mem:/ {print $2}')
        local mem_used=$(free -h | awk '/^Mem:/ {print $3}')
        echo -e "\033[1;32mMemory:\033[0m $mem_used / $mem_total"
    elif command -v vm_stat >/dev/null 2>&1; then
        local mem_total=$(sysctl -n hw.memsize 2>/dev/null | awk '{print $0/1024/1024/1024 "G"}')
        echo -e "\033[1;32mMemory:\033[0m $mem_total"
    else
        echo -e "\033[1;32mMemory:\033[0m Unknown"
    fi
    
    # Disk information
    echo -e "\033[1;32mDisk Usage:\033[0m"
    df -h | grep -v 'tmpfs\|devtmpfs' | awk '{print "  " $6 ": " $3 " / " $2 " (" $5 ")"}' | grep -v 'Mounted\|Use%'
}

# Function to monitor CPU usage
cpu_monitor() {
    echo -e "\033[1;34m=== CPU Monitor ===\033[0m"
    echo "Press Ctrl+C to exit"
    
    while true; do
        if command -v mpstat >/dev/null 2>&1; then
            mpstat 1 1 | grep -A 1 '%idle' | tail -n 1 | awk '{print "CPU Usage: " 100-$NF "%"}'  
        elif command -v top >/dev/null 2>&1; then
            top -l 1 | grep -E "^CPU" | head -1
        else
            echo "CPU monitoring tools not available"
            break
        fi
        sleep 1
    done
}

# Function to monitor memory usage
mem_monitor() {
    echo -e "\033[1;34m=== Memory Monitor ===\033[0m"
    echo "Press Ctrl+C to exit"
    
    while true; do
        if command -v free >/dev/null 2>&1; then
            free -h | grep -E "^Mem:"
        elif command -v vm_stat >/dev/null 2>&1; then
            vm_stat 1 1 | head -2
        else
            echo "Memory monitoring tools not available"
            break
        fi
        sleep 1
    done
}

# Register commands
alias sysinfo="system_info"
alias cpumon="cpu_monitor"
alias memmon="mem_monitor"
EOL

# Create Weather Widget plugin
mkdir -p "$COZYUI_DIR/plugins/weather-widget"
cat > "$COZYUI_DIR/plugins/weather-widget/weather-widget.sh" << 'EOL'
#!/bin/bash

# Weather Widget plugin for CozyUI

# Function to get weather information
get_weather() {
    local location=${1:-"auto"}
    
    if command -v curl >/dev/null 2>&1; then
        curl -s "wttr.in/$location?format=3"
    else
        echo "Weather widget requires curl. Please install curl and try again."
    fi
}

# Function to get detailed weather forecast
get_weather_forecast() {
    local location=${1:-"auto"}
    
    if command -v curl >/dev/null 2>&1; then
        curl -s "wttr.in/$location"
    else
        echo "Weather widget requires curl. Please install curl and try again."
    fi
}

# Register commands
alias weather="get_weather"
alias forecast="get_weather_forecast"
EOL

# Create shell integration
display_step "Setting up shell integration"

# Get shell config file
SHELL_CONFIG=$(get_shell_config)
display_info "Shell config file: $SHELL_CONFIG"

# Add CozyUI to shell config
cat >> "$SHELL_CONFIG" << EOL

# CozyUI Terminal Integration
export PATH="\$PATH:\$HOME/.cozyui/bin"
source "\$HOME/.cozyui/config/config.sh"
source "\$HOME/.cozyui/config/prompt.sh"
source "\$HOME/.cozyui/config/shortcuts.sh"

# CozyUI aliases
alias cozyui="\$HOME/.cozyui/bin/cozyui.sh"
alias cozyui-visual="\$HOME/.cozyui/bin/cozyui-visual.sh"

# Load CozyUI plugins
if [ "\$COZYUI_PLUGINS_AUTOLOAD" = "enabled" ]; then
    for plugin in "\$HOME/.cozyui/plugins"/*; do
        if [ -d "\$plugin" ]; then
            for script in "\$plugin"/*.sh; do
                if [ -f "\$script" ]; then
                    source "\$script"
                fi
            done
        fi
    done
fi
EOL

# Create symbolic link to make cozyui command available
ln -sf "$COZYUI_DIR/bin/cozyui.sh" "$COZYUI_DIR/bin/cozyui"
chmod +x "$COZYUI_DIR/bin/cozyui"

# Apply default theme
cp "$COZYUI_DIR/themes/dracula.theme" "$COZYUI_DIR/config/current_theme"
echo "COZYUI_THEME=dracula" > "$COZYUI_DIR/config/theme_config"

# Final steps
display_step "Finalizing installation"

# Create auto-update script
cat > "$COZYUI_DIR/bin/cozyui-update.sh" << 'EOL'
#!/bin/bash

# CozyUI Auto-Update Script
COZYUI_DIR="$HOME/.cozyui"
CONFIG_FILE="$COZYUI_DIR/config/config.sh"

# Source configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Check if auto-update is enabled
if [ "$COZYUI_AUTO_UPDATE" != "enabled" ]; then
    exit 0
fi

# Check last update time
LAST_UPDATE_FILE="$COZYUI_DIR/cache/last_update"
CURRENT_TIME=$(date +%s)

if [ -f "$LAST_UPDATE_FILE" ]; then
    LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
    DIFF=$((CURRENT_TIME - LAST_UPDATE))
    
    # Check update frequency
    case "$COZYUI_UPDATE_FREQUENCY" in
        daily)
            THRESHOLD=$((60 * 60 * 24)) # 1 day
            ;;
        weekly)
            THRESHOLD=$((60 * 60 * 24 * 7)) # 7 days
            ;;
        monthly)
            THRESHOLD=$((60 * 60 * 24 * 30)) # 30 days
            ;;
        *)
            THRESHOLD=$((60 * 60 * 24 * 7)) # Default: 7 days
            ;;
    esac
    
    if [ $DIFF -lt $THRESHOLD ]; then
        # No need to update yet
        exit 0
    fi
fi

# Update CozyUI
echo "Checking for CozyUI updates..."

# In a real scenario, this would check for updates from a server
# For this demo, we'll just update the last update time

echo "CozyUI is up to date!"
echo "$CURRENT_TIME" > "$LAST_UPDATE_FILE"
EOL

chmod +x "$COZYUI_DIR/bin/cozyui-update.sh"

# Set up cron job for auto-updates
if command_exists crontab; then
    (crontab -l 2>/dev/null; echo "0 0 * * * $COZYUI_DIR/bin/cozyui-update.sh >/dev/null 2>&1") | crontab -
    display_success "Auto-update cron job set up"
else
    display_warning "crontab not found. Auto-updates will not be scheduled."
fi

# Display installation summary
display_step "Installation complete!"

echo -e "${GREEN}CozyUI Terminal has been successfully installed.${RESET}"
echo ""
echo -e "${CYAN}What's next?${RESET}"
echo "1. Restart your terminal or run 'source $SHELL_CONFIG'"
echo "2. Run 'cozyui help' to see available commands"
echo "3. Try 'cozyui theme list' to see available themes"
echo "4. Explore plugins with 'cozyui plugin list'"
echo ""
echo -e "${YELLOW}Enjoy your enhanced terminal experience!${RESET}"