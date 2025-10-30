FROM ubuntu:22.04

# Build arguments
ARG NODE_VERSION=20
ARG GO_VERSION=1.22.1
ARG PYTHON_VERSION=3.10
ARG YQ_VERSION=v4.44.2
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    GOPATH=/home/${USERNAME}/go \
    GO_HOME=/usr/local/go \
    NVM_DIR=/home/${USERNAME}/.nvm \
    BUN_INSTALL=/home/${USERNAME}/.bun

ENV PATH=$GO_HOME/bin:$GOPATH/bin:$BUN_INSTALL/bin:$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl wget git vim nano htop tree unzip zip \
        apt-transport-https ca-certificates gnupg lsb-release locales tzdata \
        build-essential make cmake pkg-config gcc g++ gdb \
        jq netcat telnet dnsutils iputils-ping neofetch zsh tmux \
        python${PYTHON_VERSION} python3-pip python3-venv python3-dev python-is-python3 \
        mysql-client postgresql-client sqlite3 redis-tools \
        chromium-browser xvfb fonts-liberation libasound2 libatk-bridge2.0-0 \
        libdrm2 libgtk-3-0 libnspr4 libnss3 libxss1 libxtst6 xdg-utils sudo && \
    wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq && \
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    apt-get install -y ./cloudflared-linux-amd64.deb && \
    rm cloudflared-linux-amd64.deb && \
    locale-gen en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    usermod -aG docker $USERNAME

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Install Node.js via NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    bash -c "source $NVM_DIR/nvm.sh && nvm install ${NODE_VERSION} && nvm alias default ${NODE_VERSION} && nvm use default"

# Install Go
USER root
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xzf -
USER $USERNAME

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install Python packages
RUN pip install --user --upgrade pip && \
    pip install --user --no-cache-dir \
        pipenv virtualenv requests httpx flask django fastapi \
        pytest black flake8 mypy sqlalchemy pydantic uvicorn gunicorn

# Install Node.js global packages
RUN bash -c "source $NVM_DIR/nvm.sh && \
    npm install -g yarn pnpm typescript ts-node tsx nodemon pm2 \
    eslint prettier http-server"

# Install Oh My Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k && \
    git clone --depth=1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all

# Install modern CLI tools
RUN curl -sS https://webi.sh/bat | sh && \
    curl -sS https://webi.sh/exa | sh

# Configure Git
RUN git config --global init.defaultBranch main && \
    git config --global core.editor vim

# Configure Tmux
RUN printf '%s\n' \
    'set -g mouse on' \
    'set -g history-limit 10000' \
    'set -g base-index 1' \
    'setw -g pane-base-index 1' \
    > ~/.tmux.conf

# Configure Zsh
RUN printf '%s\n' \
    '' \
    '# Powerlevel10k theme' \
    'export ZSH_THEME="powerlevel10k/powerlevel10k"' \
    '' \
    '# Plugins' \
    'plugins=(' \
    '    git' \
    '    docker' \
    '    docker-compose' \
    '    zsh-autosuggestions' \
    '    zsh-syntax-highlighting' \
    '    colored-man-pages' \
    ')' \
    '' \
    '# Source Oh My Zsh' \
    'source $HOME/.oh-my-zsh/oh-my-zsh.sh' \
    '' \
    '# Modern aliases' \
    'alias ls="exa --icons"' \
    'alias la="exa -a --icons"' \
    'alias ll="exa -al --icons --header --git"' \
    'alias lt="exa --tree --level=2 --icons"' \
    'alias cat="bat"' \
    '' \
    '# Docker aliases' \
    'alias dps="docker ps"' \
    'alias dimg="docker images"' \
    'alias dstop="docker stop"' \
    'alias drm="docker rm"' \
    'alias dlog="docker logs -f"' \
    '' \
    '# Git aliases' \
    'alias gst="git status"' \
    'alias glog="git log --oneline --graph --decorate"' \
    'alias gco="git checkout"' \
    'alias gcm="git commit -m"' \
    'alias gpl="git pull"' \
    'alias gps="git push"' \
    '' \
    '# Custom functions' \
    'mkcd() { mkdir -p "$1" && cd "$1"; }' \
    'extract() {' \
    '    if [ -f "$1" ]; then' \
    '        case "$1" in' \
    '            *.tar.gz|*.tgz) tar -xzf "$1" ;;' \
    '            *.tar.bz2|*.tbz2) tar -xjf "$1" ;;' \
    '            *.zip) unzip "$1" ;;' \
    '            *.rar) unrar x "$1" ;;' \
    '            *) echo "Unknown archive format" ;;' \
    '        esac' \
    '    else' \
    '        echo "File not found: $1"' \
    '    fi' \
    '}' \
    >> ~/.zshrc

# Create workspace directory
RUN mkdir -p /home/$USERNAME/workspace

WORKDIR /home/$USERNAME/workspace

# Create startup script inline
RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    '' \
    'check_version() {' \
    '    local command_to_run=$1' \
    '    local name=$2' \
    '    local version' \
    '    version=$(eval "$command_to_run" 2>/dev/null || echo "")' \
    '    if [ -n "$version" ]; then' \
    '        printf "  \033[1;37m%-20s\033[0m \033[1;32m%s\033[0m\n" "$name:" "$version"' \
    '    else' \
    '        printf "  \033[1;37m%-20s\033[0m \033[1;31mNot Found\033[0m\n" "$name:"' \
    '    fi' \
    '}' \
    '' \
    'clear' \
    'echo -e "\033[1;36m"' \
    'cat << "BANNER"' \
    '╔═══════════════════════════════════════════════════════════╗' \
    '║                                                           ║' \
    '║       🚀  Welcome to DevContainer Environment  🚀        ║' \
    '║                                                           ║' \
    '╚═══════════════════════════════════════════════════════════╝' \
    'BANNER' \
    'echo -e "\033[0m"' \
    '' \
    'if command -v neofetch &> /dev/null; then' \
    '    neofetch --stdout' \
    'fi' \
    '' \
    'echo -e "\n\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"' \
    'echo -e "\033[1;34m  🛠️  Software Versions\033[0m"' \
    'echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"' \
    '' \
    'if [ -s "$NVM_DIR/nvm.sh" ]; then' \
    '    source "$NVM_DIR/nvm.sh" --no-use 2>/dev/null' \
    '    nvm use default &>/dev/null || true' \
    'fi' \
    '' \
    'if [ -s "$BUN_INSTALL/_env" ]; then' \
    '    source "$BUN_INSTALL/_env" 2>/dev/null || true' \
    'fi' \
    '' \
    'echo -e "\n\033[1;33m▶ Languages & Runtimes\033[0m"' \
    'check_version "python3 --version 2>&1 | cut -d\" \" -f2" "Python"' \
    'check_version "node --version 2>&1 | sed \"s/v//\"" "Node.js"' \
    'check_version "go version 2>&1 | awk \"{print \\\$3}\" | sed \"s/go//\"" "Go"' \
    'check_version "bun --version 2>&1" "Bun"' \
    '' \
    'echo -e "\n\033[1;33m▶ Package Managers\033[0m"' \
    'check_version "pip --version 2>&1 | cut -d\" \" -f2" "pip"' \
    'check_version "npm --version 2>&1" "npm"' \
    'check_version "yarn --version 2>&1" "yarn"' \
    'check_version "pnpm --version 2>&1" "pnpm"' \
    'check_version "pm2 --version 2>&1" "PM2"' \
    '' \
    'echo -e "\n\033[1;33m▶ DevOps & Tools\033[0m"' \
    'check_version "docker --version 2>&1 | cut -d\" \" -f3 | tr -d \",\"" "Docker"' \
    'check_version "docker compose version 2>&1 | grep -oP \"v\K[0-9.]+\" | head -1" "Docker Compose"' \
    'check_version "git --version 2>&1 | cut -d\" \" -f3" "Git"' \
    'check_version "jq --version 2>&1 | sed \"s/jq-//\"" "jq"' \
    'check_version "yq --version 2>&1 | awk \"{print \\\$NF}\"" "yq"' \
    '' \
    'echo -e "\n\033[1;33m▶ Database Clients\033[0m"' \
    'check_version "mysql --version 2>&1 | grep -oP \"\d+\.\d+\.\d+\" | head -1" "MySQL Client"' \
    'check_version "psql --version 2>&1 | awk \"{print \\\$3}\"" "PostgreSQL Client"' \
    'check_version "sqlite3 --version 2>&1 | awk \"{print \\\$1}\"" "SQLite3"' \
    'check_version "redis-cli --version 2>&1 | awk \"{print \\\$2}\"" "Redis CLI"' \
    '' \
    'echo -e "\n\033[1;33m▶ Browser\033[0m"' \
    'check_version "chromium-browser --version 2>&1 | cut -d\" \" -f2" "Chromium"' \
    '' \
    'echo -e "\n\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"' \
    'echo -e "\033[1;36m  📁  Workspace Information\033[0m"' \
    'echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"' \
    'echo -e "  \033[1;37mCurrent User:\033[0m      \033[1;32m$(whoami)\033[0m"' \
    'echo -e "  \033[1;37mHome Directory:\033[0m    \033[1;32m$HOME\033[0m"' \
    'echo -e "  \033[1;37mWorking Directory:\033[0m \033[1;32m$(pwd)\033[0m"' \
    'echo -e "  \033[1;37mShell:\033[0m             \033[1;32m$SHELL\033[0m"' \
    'echo -e "  \033[1;37mTimezone:\033[0m          \033[1;32m$TZ\033[0m"' \
    '' \
    'echo -e "\n\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"' \
    'echo -e "\033[1;36m  💡  Quick Tips\033[0m"' \
    'echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"' \
    'echo -e "  \033[1;33m•\033[0m Use \033[1;32mll\033[0m for better file listing"' \
    'echo -e "  \033[1;33m•\033[0m Use \033[1;32mcat\033[0m (bat) for syntax-highlighted viewing"' \
    'echo -e "  \033[1;33m•\033[0m Press \033[1;32mCtrl+R\033[0m for command history search (fzf)"' \
    'echo -e "  \033[1;33m•\033[0m Use \033[1;32mmkcd <dir>\033[0m to create and enter directory"' \
    'echo -e "  \033[1;33m•\033[0m Docker commands: \033[1;32mdps\033[0m, \033[1;32mdimg\033[0m, \033[1;32mdlog\033[0m"' \
    'echo -e "  \033[1;33m•\033[0m Git shortcuts: \033[1;32mgst\033[0m, \033[1;32mglog\033[0m, \033[1;32mgco\033[0m"' \
    '' \
    'echo -e "\n\033[1;32m✨ Environment is ready! Happy coding! ✨\033[0m\n"' \
    '' \
    'exec /bin/zsh' \
    > /usr/local/bin/startup.sh && \
    chmod +x /usr/local/bin/startup.sh

# Expose common development ports
EXPOSE 3000 5000 8000 8080 9000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep zsh || exit 1

# Default command - keeps container running
CMD ["/bin/bash", "/usr/local/bin/startup.sh"]
