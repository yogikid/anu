FROM ubuntu:22.04

# Build arguments
ARG NODE_VERSION=20
ARG GO_VERSION=1.22.1
ARG PYTHON_VERSION=3.10
ARG YQ_VERSION=v4.44.2

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    HOME=/home/container \
    GOPATH=/home/container/go \
    GO_HOME=/usr/local/go \
    BUN_INSTALL=/opt/bun \
    DISPLAY=:1 \
    XDG_RUNTIME_DIR=/tmp/runtime-container

ENV PATH=$GO_HOME/bin:$GOPATH/bin:$BUN_INSTALL/bin:/home/container/.local/bin:$PATH

# Install system dependencies + XFCE Desktop + VNC
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl wget git vim nano htop tree unzip zip \
    apt-transport-https ca-certificates gnupg lsb-release locales tzdata \
    build-essential make cmake pkg-config gcc g++ gdb \
    jq netcat telnet dnsutils iputils-ping neofetch \
    python${PYTHON_VERSION} python3-pip python3-venv python3-dev python-is-python3 \
    mysql-client postgresql-client sqlite3 redis-tools \
    xvfb \
    fonts-liberation libasound2 libatk-bridge2.0-0 \
    libdrm2 libgtk-3-0 libnspr4 libnss3 libxss1 libxtst6 xdg-utils \
    ffmpeg imagemagick graphicsmagick \
    sox libsox-fmt-all \
    tesseract-ocr tesseract-ocr-eng tesseract-ocr-ind \
    aria2 git-lfs \
    webp libwebp-dev \
    libnss-wrapper gettext-base \
    xfce4 xfce4-goodies xfce4-terminal \
    dbus-x11 x11-xserver-utils \
    tigervnc-standalone-server tigervnc-common tigervnc-tools \
    at-spi2-core \
    tumbler tumbler-plugins-extra \
    firefox firefox-locale-en firefox-locale-id \
    gedit mousepad \
    file-roller p7zip-full p7zip-rar unrar \
    gdebi-core \
    synaptic software-properties-common \
    zenity xterm \
    supervisor \
    tmux \
    fuse \
    libnghttp2-14 \ 
    && \
    wget -q https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq && \
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    apt-get install -y ./cloudflared-linux-amd64.deb && \
    rm cloudflared-linux-amd64.deb && \
    locale-gen en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Rclone
RUN curl https://rclone.org/install.sh | bash



# Install WPS Office
RUN cd /tmp && \
    apt-get update && \
    apt-get install -y bsdmainutils && \
    wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb && \
    apt-get install -y /tmp/wps-office_*.deb || apt-get install -yf && \
    rm /tmp/wps-office_*.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Additional Tools
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod +x /usr/local/bin/yt-dlp

# Install Java (Optional - hanya jika mau main Java Edition)
RUN apt-get update && \
    apt-get install -y openjdk-17-jre-headless && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install MongoDB Tools
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && \
    apt-get install -y mongodb-mongosh mongodb-database-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xzf -

# Create Go symlink
RUN ln -sf /usr/local/go/bin/go /usr/local/bin/go && \
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Verify Node.js and create symlinks
RUN which node || (echo "Node not found!" && exit 1) && \
    which npm || ln -sf /usr/bin/nodejs /usr/local/bin/node || true && \
    npm --version || (echo "npm not found!" && exit 1)

# Create Node.js symlinks
RUN ln -sf /usr/bin/node /usr/local/bin/node && \
    ln -sf /usr/bin/npm /usr/local/bin/npm && \
    ln -sf /usr/bin/npx /usr/local/bin/npx

# Install Node.js Global Packages
RUN npm install -g yarn pnpm typescript ts-node tsx nodemon pm2 \
    eslint prettier http-server prisma newman && \
    npm cache clean --force && \
    ln -sf /usr/lib/node_modules/ts-node/dist/bin.js /usr/local/bin/ts-node && \
    ln -sf /usr/lib/node_modules/tsx/dist/cli.mjs /usr/local/bin/tsx && \
    chmod +x /usr/local/bin/ts-node /usr/local/bin/tsx

# Create yarn and pnpm symlinks
RUN ln -sf /usr/bin/yarn /usr/local/bin/yarn && \
    ln -sf /usr/bin/pnpm /usr/local/bin/pnpm

# Install Bun
RUN mkdir -p $BUN_INSTALL && \
    curl -fsSL https://bun.sh/install | BUN_INSTALL=$BUN_INSTALL bash && \
    chmod -R 755 $BUN_INSTALL

# Install Python Packages (with fix for blinker conflict)
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --ignore-installed blinker setuptools \
    pipenv virtualenv requests httpx flask django fastapi \
    pytest black flake8 mypy sqlalchemy pydantic uvicorn gunicorn \
    aiohttp pillow python-dotenv redis pymongo motor \
    yt-dlp python-telegram-bot discord.py

# Create Python symlinks
RUN ln -sf /usr/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/bin/python3 /usr/local/bin/python3 && \
    ln -sf /usr/bin/pip3 /usr/local/bin/pip && \
    ln -sf /usr/bin/pip3 /usr/local/bin/pip3

# Git Configuration
RUN git config --system init.defaultBranch main && \
    git config --system core.editor vim && \
    git config --system --add safe.directory '*' && \
    git lfs install --system

# Create base directories
RUN mkdir -p /home/container /home/container/go /home/container/Documents /home/container/Downloads && \
    chmod -R 777 /home/container

# ============================================
# MCPE SERVER SCRIPT
# ============================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    'PORT=${1:-19132}' \
    'DIR="/home/container/mcpe-$PORT"' \
    'mkdir -p "$DIR"' \
    'cd "$DIR" || exit 1' \
    'if [ ! -f "bedrock_server" ]; then' \
    '    echo "⬇️  Downloading Minecraft Bedrock Server..."' \
    '    wget -q -O bedrock-server.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-1.20.72.01.zip' \
    '    unzip -q bedrock-server.zip' \
    '    rm bedrock-server.zip' \
    '    chmod +x bedrock_server' \
    'fi' \
    '# Update port in server.properties' \
    'if [ -f "server.properties" ]; then' \
    '    sed -i "s/server-port=.*/server-port=$PORT/g" server.properties' \
    '    sed -i "s/server-portv6=.*/server-portv6=$PORT/g" server.properties' \
    'else' \
    '    echo "server-port=$PORT" > server.properties' \
    '    echo "server-portv6=$PORT" >> server.properties' \
    'fi' \
    'echo "✅ Starting MCPE Server on Port $PORT..."' \
    'export LD_LIBRARY_PATH=.' \
    './bedrock_server' \
    > /usr/local/bin/start-mc && \
    chmod +x /usr/local/bin/start-mc

# ============================================
# XFCE Configuration
# ============================================
RUN mkdir -p /etc/skel/.config/xfce4 /etc/skel/Desktop && \
    echo 'export NO_AT_BRIDGE=1' >> /etc/skel/.profile && \
    echo '[Default Applications]' > /etc/skel/.config/mimeapps.list && \
    echo 'text/html=firefox.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'x-scheme-handler/http=firefox.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'x-scheme-handler/https=firefox.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'application/pdf=wps-office-pdf.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'application/msword=wps-office-wps.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'application/vnd.ms-excel=wps-office-et.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'application/vnd.ms-powerpoint=wps-office-wpp.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo '#!/bin/bash' > /usr/bin/pm-is-supported && \
    echo 'exit 1' >> /usr/bin/pm-is-supported && \
    chmod +x /usr/bin/pm-is-supported

# Desktop Shortcuts
RUN echo '[Desktop Entry]' > /etc/skel/Desktop/firefox.desktop && \
    echo 'Version=1.0' >> /etc/skel/Desktop/firefox.desktop && \
    echo 'Type=Application' >> /etc/skel/Desktop/firefox.desktop && \
    echo 'Name=Firefox' >> /etc/skel/Desktop/firefox.desktop && \
    echo 'Comment=Web Browser' >> /etc/skel/Desktop/firefox.desktop && \
    echo 'Exec=firefox %u' >> /etc/skel/Desktop/firefox.desktop && \
    echo 'Icon=firefox' >> /etc/skel/Desktop/firefox.desktop && \
    echo 'Terminal=false' >> /etc/skel/Desktop/firefox.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /etc/skel/Desktop/firefox.desktop && \
    chmod +x /etc/skel/Desktop/firefox.desktop && \
    echo '[Desktop Entry]' > /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Version=1.0' >> /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Type=Application' >> /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Name=WPS Writer' >> /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Comment=Word Processor' >> /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Exec=wps %F' >> /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Icon=wps-office2019-wpsmain' >> /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Terminal=false' >> /etc/skel/Desktop/wps-writer.desktop && \
    echo 'Categories=Office;' >> /etc/skel/Desktop/wps-writer.desktop && \
    chmod +x /etc/skel/Desktop/wps-writer.desktop && \
    echo '[Desktop Entry]' > /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Version=1.0' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Type=Application' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Name=WPS Spreadsheet' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Comment=Spreadsheet Editor' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Exec=et %F' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Icon=wps-office2019-etmain' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Terminal=false' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo 'Categories=Office;' >> /etc/skel/Desktop/wps-spreadsheet.desktop && \
    chmod +x /etc/skel/Desktop/wps-spreadsheet.desktop && \
    echo '[Desktop Entry]' > /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Version=1.0' >> /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Type=Application' >> /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Name=WPS Presentation' >> /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Comment=Presentation Editor' >> /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Exec=wpp %F' >> /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Icon=wps-office2019-wppmain' >> /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Terminal=false' >> /etc/skel/Desktop/wps-presentation.desktop && \
    echo 'Categories=Office;' >> /etc/skel/Desktop/wps-presentation.desktop && \
    chmod +x /etc/skel/Desktop/wps-presentation.desktop && \
    echo '[Desktop Entry]' > /etc/skel/Desktop/file-manager.desktop && \
    echo 'Version=1.0' >> /etc/skel/Desktop/file-manager.desktop && \
    echo 'Type=Application' >> /etc/skel/Desktop/file-manager.desktop && \
    echo 'Name=File Manager' >> /etc/skel/Desktop/file-manager.desktop && \
    echo 'Comment=Browse Files' >> /etc/skel/Desktop/file-manager.desktop && \
    echo 'Exec=thunar' >> /etc/skel/Desktop/file-manager.desktop && \
    echo 'Icon=system-file-manager' >> /etc/skel/Desktop/file-manager.desktop && \
    echo 'Terminal=false' >> /etc/skel/Desktop/file-manager.desktop && \
    echo 'Categories=System;' >> /etc/skel/Desktop/file-manager.desktop && \
    chmod +x /etc/skel/Desktop/file-manager.desktop

# ============================================
# VNC DESKTOP SCRIPT (FIXED)
# ============================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    '# --- FIX START: Force User Identity ---' \
    'export USER=container' \
    'export LOGNAME=container' \
    'export HOME=/home/container' \
    '# --- FIX END ---' \
    '' \
    'PORT=${1:-5901}' \
    'VNC_PASS=${VNC_PASSWORD:-${RDP_PASSWORD:-admin123}}' \
    'VNC_DIR="/home/container/.vnc"' \
    'DISPLAY_NUM=":1"' \
    'GEOMETRY="${VNC_GEOMETRY:-1920x1080}"' \
    'DEPTH="${VNC_DEPTH:-24}"' \
    'RED="\033[0;31m"' \
    'GREEN="\033[0;32m"' \
    'YELLOW="\033[0;33m"' \
    'BLUE="\033[0;34m"' \
    'CYAN="\033[0;36m"' \
    'RESET="\033[0m"' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo -e "${CYAN}     Starting XFCE Desktop via VNC      ${RESET}"' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo -e "${BLUE}Port:${RESET}     ${CYAN}$PORT${RESET}"' \
    'echo -e "${BLUE}Display:${RESET}  ${CYAN}$DISPLAY_NUM${RESET}"' \
    'echo -e "${BLUE}Geometry:${RESET} ${CYAN}$GEOMETRY${RESET}"' \
    'echo -e "${BLUE}User:${RESET}     ${CYAN}$USER${RESET}"' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo ""' \
    'cleanup() {' \
    '    echo ""' \
    '    echo -e "${YELLOW}Shutting down VNC server...${RESET}"' \
    '    vncserver -kill "$DISPLAY_NUM" 2>/dev/null || true' \
    '    rm -rf /tmp/.X11-unix/X1 /tmp/.X1-lock' \
    '    exit 0' \
    '}' \
    'trap cleanup SIGTERM SIGINT' \
    '# Clean stale locks' \
    'vncserver -kill "$DISPLAY_NUM" 2>/dev/null || true' \
    'rm -rf /tmp/.X11-unix/X1 /tmp/.X1-lock' \
    'sleep 1' \
    'mkdir -p "$VNC_DIR"' \
    'chmod 700 "$VNC_DIR"' \
    '# Set Password' \
    'if command -v tigervncpasswd &> /dev/null; then' \
    '    echo "$VNC_PASS" | tigervncpasswd -f > "$VNC_DIR/passwd" 2>/dev/null' \
    'elif command -v vncpasswd &> /dev/null; then' \
    '    echo "$VNC_PASS" | vncpasswd -f > "$VNC_DIR/passwd" 2>/dev/null' \
    'fi' \
    'chmod 600 "$VNC_DIR/passwd"' \
    '# Create xstartup' \
    'cat > "$VNC_DIR/xstartup" << '\''XEOF'\''' \
    '#!/bin/bash' \
    'export HOME=/home/container' \
    'export XDG_RUNTIME_DIR=/tmp/runtime-container' \
    'export DISPLAY=:1' \
    'export NO_AT_BRIDGE=1' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'exec startxfce4' \
    'XEOF' \
    'chmod +x "$VNC_DIR/xstartup"' \
    '# Start Server' \
    'vncserver "$DISPLAY_NUM" \' \
    '    -geometry "$GEOMETRY" \' \
    '    -depth "$DEPTH" \' \
    '    -rfbport "$PORT" \' \
    '    -localhost no \' \
    '    -SecurityTypes VncAuth \' \
    '    -AlwaysShared \' \
    '    2>&1 | tee "$VNC_DIR/startup.log"' \
    'sleep 3' \
    'if pgrep -f "Xtigervnc.*$DISPLAY_NUM" > /dev/null; then' \
    '    echo ""' \
    '    echo -e "${GREEN}✅ VNC Server Started!${RESET}"' \
    '    echo -e "${CYAN}Use IP:YOUR_PORT to connect.${RESET}"' \
    '    tail -f "$VNC_DIR"/*.log 2>/dev/null &' \
    '    TAIL_PID=$!' \
    '    while pgrep -f "Xtigervnc.*$DISPLAY_NUM" > /dev/null; do' \
    '        sleep 5' \
    '    done' \
    '    kill $TAIL_PID 2>/dev/null || true' \
    'else' \
    '    echo -e "${RED}❌ Failed to start VNC! Check logs:${RESET}"' \
    '    cat "$VNC_DIR/startup.log"' \
    '    exit 1' \
    'fi' \
    > /usr/local/bin/desktop && \
    chmod +x /usr/local/bin/desktop
    
# Stop Desktop
RUN printf '%s\n' \
    '#!/bin/bash' \
    'vncserver -kill :1 2>/dev/null && echo "✅ VNC stopped" || echo "⚠️  No VNC running"' \
    'pkill -f Xtigervnc 2>/dev/null || true' \
    > /usr/local/bin/stop-desktop && \
    chmod +x /usr/local/bin/stop-desktop

# List Desktop
RUN printf '%s\n' \
    '#!/bin/bash' \
    'echo "═══════════════════════════════════════"' \
    'echo "       Active VNC Sessions"' \
    'echo "═══════════════════════════════════════"' \
    'vncserver -list 2>/dev/null || echo "No VNC sessions"' \
    > /usr/local/bin/list-desktop && \
    chmod +x /usr/local/bin/list-desktop

# Restart Desktop
RUN printf '%s\n' \
    '#!/bin/bash' \
    'PORT=${1:-5901}' \
    'stop-desktop' \
    'sleep 2' \
    'desktop "$PORT"' \
    > /usr/local/bin/restart-desktop && \
    chmod +x /usr/local/bin/restart-desktop

# Custom Bashrc
RUN printf '%s\n' \
    'RED="\033[0;31m"' \
    'GREEN="\033[0;32m"' \
    'YELLOW="\033[0;33m"' \
    'BLUE="\033[0;34m"' \
    'CYAN="\033[0;36m"' \
    'WHITE="\033[1;37m"' \
    'RESET="\033[0m"' \
    'alias ll="ls -alh --color=auto"' \
    'export PS1="\[\033[1;36m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "' \
    'show_info() {' \
    '    clear' \
    '    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"' \
    '    echo -e "${CYAN}║${RESET}     ${WHITE}VNC Desktop Container - Office & Development${RESET}             ${CYAN}║${RESET}"' \
    '    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"' \
    '    echo ""' \
    '    echo -e "${GREEN}💻 System:${RESET}"' \
    '    echo -e "   CPU: ${YELLOW}$(nproc) cores${RESET}"' \
    '    echo -e "   RAM: ${YELLOW}$(free -h | awk "/Mem:/ {print \$3\" / \"\$2}")${RESET}"' \
    '    echo -e "   Disk: ${YELLOW}$(df -h /home/container | tail -1 | awk '\''{print $3\" / \"$2}'\'')${RESET}"' \
    '    echo ""' \
    '    echo -e "${GREEN}🖥️  Desktop Commands:${RESET}"' \
    '    echo -e "   ${CYAN}desktop [port]${RESET}      - Start VNC (default: 5901)"' \
    '    echo -e "   ${CYAN}stop-desktop${RESET}        - Stop VNC"' \
    '    echo -e "   ${CYAN}list-desktop${RESET}        - List active sessions"' \
    '    echo -e "   ${CYAN}restart-desktop${RESET}     - Restart VNC"' \
    '    echo ""' \
    '    echo -e "${GREEN}📦 Installed Applications:${RESET}"' \
    '    echo -e "   • Firefox Browser"' \
    '    echo -e "   • WPS Office (Writer, Spreadsheet, Presentation)"' \
    '    echo -e "   • Rclone (cloud storage sync)"' \
    '    echo -e "   • Development tools (Node.js, Python, Go, Bun)"' \
    '    echo ""' \
    '    echo -e "${GREEN}🔧 Useful Commands:${RESET}"' \
    '    echo -e "   ${CYAN}rclone config${RESET}       - Configure cloud storage"' \
    '    echo -e "   ${CYAN}firefox${RESET}             - Launch Firefox (in VNC)"' \
    '    echo ""' \
    '}' \
    'if [ "$SHLVL" = "1" ]; then' \
    '    show_info' \
    'fi' \
    > /etc/bash.bashrc.custom && \
    cat /etc/bash.bashrc.custom >> /etc/bash.bashrc && \
    rm /etc/bash.bashrc.custom

# Default index.js
RUN printf '%s\n' \
    'console.log("╔═══════════════════════════════════════════════════╗");' \
    'console.log("║   VNC Desktop Container Ready!                    ║");' \
    'console.log("╚═══════════════════════════════════════════════════╝");' \
    'console.log("");' \
    'console.log("🖥️  Start Desktop: desktop 5901");' \
    'console.log("📦 WPS Office, Firefox, Rclone installed");' \
    'console.log("");' \
    > /home/container/index.js && \
    chmod 644 /home/container/index.js

# Entrypoint Script
RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    'cd /home/container || exit 1' \
    'export USER_ID=$(id -u)' \
    'export GROUP_ID=$(id -g)' \
    'export USER_NAME=${USER:-container}' \
    'echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Container User:/home/container:/bin/bash" > /tmp/passwd' \
    'echo "${USER_NAME}:x:${GROUP_ID}:" > /tmp/group' \
    'export LD_PRELOAD=libnss_wrapper.so' \
    'export NSS_WRAPPER_PASSWD=/tmp/passwd' \
    'export NSS_WRAPPER_GROUP=/tmp/group' \
    'ln -sf /usr/bin/node /usr/local/bin/node 2>/dev/null || true' \
    'ln -sf /usr/bin/npm /usr/local/bin/npm 2>/dev/null || true' \
    'ln -sf /usr/bin/npx /usr/local/bin/npx 2>/dev/null || true' \
    'ln -sf /usr/bin/yarn /usr/local/bin/yarn 2>/dev/null || true' \
    'ln -sf /usr/bin/pnpm /usr/local/bin/pnpm 2>/dev/null || true' \
    'ln -sf /usr/local/go/bin/go /usr/local/bin/go 2>/dev/null || true' \
    'ln -sf /usr/bin/python3 /usr/local/bin/python 2>/dev/null || true' \
    'ln -sf /usr/bin/pip3 /usr/local/bin/pip 2>/dev/null || true' \
    'mkdir -p /tmp/runtime-container /home/container/.vnc' \
    'chmod 700 /tmp/runtime-container /home/container/.vnc' \
    'export HOME=/home/container' \
    'export XDG_RUNTIME_DIR=/tmp/runtime-container' \
    'export VNC_PASSWORD=${VNC_PASSWORD:-${RDP_PASSWORD:-admin123}}' \
    'echo "╔═══════════════════════════════════════════════════╗"' \
    'echo "║   VNC Desktop Container Started!                  ║"' \
    'echo "╚═══════════════════════════════════════════════════╝"' \
    'echo ""' \
    'echo "🖥️  Desktop Ready! Start with: desktop 5901"' \
    'echo ""' \
    'if [ ! -f "/home/container/index.js" ]; then' \
    '    echo "// Start VNC Desktop with: desktop 5901" > /home/container/index.js' \
    'fi' \
    'exec /bin/bash' \
    > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set ownership
RUN chown -R 1000:1000 /home/container
