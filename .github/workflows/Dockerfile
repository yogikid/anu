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
    jq netcat telnet dnsutils iputils-ping neofetch net-tools \
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
    procps \
    geoip-bin geoip-database \
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

# Install Java
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

# Install Python Packages
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
# MINECRAFT BEDROCK SERVER SCRIPT (FIXED)
# ============================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    'PORT=${1:-19132}' \
    'VERSION="1.21.124.2"' \
    'DIR="/home/container/mcpe-$PORT"' \
    '' \
    'RED="\033[0;31m"' \
    'GREEN="\033[0;32m"' \
    'YELLOW="\033[0;33m"' \
    'CYAN="\033[0;36m"' \
    'RESET="\033[0m"' \
    '' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo -e "${CYAN}  Minecraft Bedrock Server Launcher${RESET}"' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo -e "${YELLOW}Port: $PORT${RESET}"' \
    'echo -e "${YELLOW}Version: $VERSION${RESET}"' \
    'echo ""' \
    '' \
    'mkdir -p "$DIR"' \
    'cd "$DIR" || exit 1' \
    '' \
    'if [ ! -f "bedrock_server" ]; then' \
    '    echo -e "${CYAN}📥 Downloading Minecraft Bedrock Server...${RESET}"' \
    '    wget -U "Mozilla/5.0" -O bedrock.zip "https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-${VERSION}.zip"' \
    '    ' \
    '    if [ $? -ne 0 ]; then' \
    '        echo -e "${RED}❌ Download failed!${RESET}"' \
    '        exit 1' \
    '    fi' \
    '    ' \
    '    echo -e "${CYAN}📦 Extracting files...${RESET}"' \
    '    unzip -o bedrock.zip' \
    '    rm bedrock.zip' \
    '    chmod +x bedrock_server' \
    '    echo -e "${GREEN}✅ Download complete!${RESET}"' \
    'fi' \
    '' \
    '# Update port in server.properties' \
    'if [ -f "server.properties" ]; then' \
    '    sed -i "s/server-port=.*/server-port=$PORT/g" server.properties' \
    '    sed -i "s/server-portv6=.*/server-portv6=$PORT/g" server.properties' \
    'else' \
    '    echo "server-port=$PORT" > server.properties' \
    '    echo "server-portv6=$PORT" >> server.properties' \
    '    echo "server-name=Bedrock Server" >> server.properties' \
    '    echo "gamemode=survival" >> server.properties' \
    '    echo "difficulty=normal" >> server.properties' \
    '    echo "max-players=10" >> server.properties' \
    'fi' \
    '' \
    'echo ""' \
    'echo -e "${GREEN}✅ Starting Minecraft Bedrock Server on Port $PORT...${RESET}"' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo ""' \
    '' \
    'export LD_LIBRARY_PATH=.' \
    './bedrock_server' \
    > /usr/local/bin/start-mc && \
    chmod +x /usr/local/bin/start-mc

# ============================================
# XFCE Configuration
# ============================================
RUN mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml /etc/skel/Desktop && \
    echo 'export NO_AT_BRIDGE=1' >> /etc/skel/.profile && \
    echo 'export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-session' >> /etc/skel/.profile && \
    echo '[Default Applications]' > /etc/skel/.config/mimeapps.list && \
    echo 'text/html=firefox.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'x-scheme-handler/http=firefox.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'x-scheme-handler/https=firefox.desktop' >> /etc/skel/.config/mimeapps.list && \
    echo 'application/pdf=wps-office-pdf.desktop' >> /etc/skel/.config/mimeapps.list && \
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
# VNC DESKTOP SCRIPT (COMPLETELY FIXED)
# ============================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    '' \
    '# Force proper user identity' \
    'export USER=${USER:-container}' \
    'export LOGNAME=${USER}' \
    'export HOME=/home/container' \
    'export XDG_RUNTIME_DIR=/tmp/runtime-container' \
    '' \
    'PORT=${1:-5901}' \
    'VNC_PASS=${VNC_PASSWORD:-${RDP_PASSWORD:-admin123}}' \
    'VNC_DIR="/home/container/.vnc"' \
    'DISPLAY_NUM=":1"' \
    'GEOMETRY="${VNC_GEOMETRY:-1920x1080}"' \
    'DEPTH="${VNC_DEPTH:-24}"' \
    '' \
    'RED="\033[0;31m"' \
    'GREEN="\033[0;32m"' \
    'YELLOW="\033[0;33m"' \
    'CYAN="\033[0;36m"' \
    'RESET="\033[0m"' \
    '' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo -e "${CYAN}     Starting XFCE Desktop via VNC${RESET}"' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo -e "Port:     ${CYAN}$PORT${RESET}"' \
    'echo -e "Display:  ${CYAN}$DISPLAY_NUM${RESET}"' \
    'echo -e "Geometry: ${CYAN}$GEOMETRY${RESET}"' \
    'echo -e "User:     ${CYAN}$USER${RESET}"' \
    'echo -e "${CYAN}=========================================${RESET}"' \
    'echo ""' \
    '' \
    '# Cleanup function' \
    'cleanup() {' \
    '    echo ""' \
    '    echo -e "${YELLOW}🛑 Shutting down VNC server...${RESET}"' \
    '    vncserver -kill "$DISPLAY_NUM" 2>/dev/null || true' \
    '    pkill -f "Xtigervnc.*$DISPLAY_NUM" 2>/dev/null || true' \
    '    rm -rf /tmp/.X11-unix/X1 /tmp/.X1-lock' \
    '    exit 0' \
    '}' \
    '' \
    'trap cleanup SIGTERM SIGINT EXIT' \
    '' \
    '# Clean stale processes and locks' \
    'vncserver -kill "$DISPLAY_NUM" 2>/dev/null || true' \
    'pkill -f "Xtigervnc.*$DISPLAY_NUM" 2>/dev/null || true' \
    'rm -rf /tmp/.X11-unix/X1 /tmp/.X1-lock' \
    'sleep 1' \
    '' \
    '# Setup VNC directory' \
    'mkdir -p "$VNC_DIR" /tmp/runtime-container' \
    'chmod 700 "$VNC_DIR" /tmp/runtime-container' \
    '' \
    '# Set VNC password' \
    'echo "$VNC_PASS" | vncpasswd -f > "$VNC_DIR/passwd" 2>/dev/null' \
    'chmod 600 "$VNC_DIR/passwd"' \
    '' \
    '# Create xstartup script' \
    'cat > "$VNC_DIR/xstartup" << '\''XEOF'\''' \
    '#!/bin/bash' \
    'export HOME=/home/container' \
    'export XDG_RUNTIME_DIR=/tmp/runtime-container' \
    'export DISPLAY=:1' \
    'export NO_AT_BRIDGE=1' \
    'export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-session' \
    'unset SESSION_MANAGER' \
    '' \
    '# Start D-Bus' \
    'if [ ! -f /tmp/dbus-session ]; then' \
    '    dbus-daemon --session --fork --address=unix:path=/tmp/dbus-session 2>/dev/null' \
    'fi' \
    '' \
    '# Start XFCE' \
    'exec startxfce4' \
    'XEOF' \
    'chmod +x "$VNC_DIR/xstartup"' \
    '' \
    '# Start VNC Server' \
    'echo -e "${CYAN}🚀 Starting VNC Server...${RESET}"' \
    'vncserver "$DISPLAY_NUM" \' \
    '    -geometry "$GEOMETRY" \' \
    '    -depth "$DEPTH" \' \
    '    -rfbport "$PORT" \' \
    '    -localhost no \' \
    '    -SecurityTypes VncAuth \' \
    '    -AlwaysShared \' \
    '    -xstartup "$VNC_DIR/xstartup" \' \
    '    2>&1 | tee "$VNC_DIR/startup.log"' \
    '' \
    'sleep 3' \
    '' \
    '# Verify VNC is running' \
    'if pgrep -f "Xtigervnc.*$DISPLAY_NUM" > /dev/null; then' \
    '    echo ""' \
    '    echo -e "${GREEN}✅ VNC Server Started Successfully!${RESET}"' \
    '    echo -e "${CYAN}📡 Connect to: YOUR_IP:$PORT${RESET}"' \
    '    echo -e "${CYAN}🔑 Password: $VNC_PASS${RESET}"' \
    '    echo ""' \
    '    ' \
    '    # Keep container alive and show logs' \
    '    tail -f "$VNC_DIR"/*.log 2>/dev/null &' \
    '    TAIL_PID=$!' \
    '    ' \
    '    while pgrep -f "Xtigervnc.*$DISPLAY_NUM" > /dev/null; do' \
    '        sleep 5' \
    '    done' \
    '    ' \
    '    kill $TAIL_PID 2>/dev/null || true' \
    'else' \
    '    echo -e "${RED}❌ Failed to start VNC!${RESET}"' \
    '    echo -e "${RED}Check logs:${RESET}"' \
    '    cat "$VNC_DIR/startup.log"' \
    '    exit 1' \
    'fi' \
    > /usr/local/bin/desktop && \
    chmod +x /usr/local/bin/desktop

# Stop Desktop
RUN printf '%s\n' \
    '#!/bin/bash' \
    'vncserver -kill :1 2>/dev/null && echo "✅ VNC stopped" || echo "⚠️ No VNC running"' \
    'pkill -f Xtigervnc 2>/dev/null || true' \
    'rm -rf /tmp/.X11-unix/X1 /tmp/.X1-lock' \
    > /usr/local/bin/stop-desktop && \
    chmod +x /usr/local/bin/stop-desktop

# List Desktop
RUN printf '%s\n' \
    '#!/bin/bash' \
    'echo "═══════════════════════════════════════"' \
    'echo "       Active VNC Sessions"' \
    'echo "═══════════════════════════════════════"' \
    'if pgrep -f Xtigervnc > /dev/null; then' \
    '    vncserver -list 2>/dev/null || echo "VNC is running on :1"' \
    'else' \
    '    echo "No VNC sessions running"' \
    'fi' \
    > /usr/local/bin/list-desktop && \
    chmod +x /usr/local/bin/list-desktop

# Restart Desktop
RUN printf '%s\n' \
    '#!/bin/bash' \
    'PORT=${1:-5901}' \
    'echo "🔄 Restarting VNC Desktop..."' \
    'stop-desktop' \
    'sleep 2' \
    'desktop "$PORT"' \
    > /usr/local/bin/restart-desktop && \
    chmod +x /usr/local/bin/restart-desktop

# ============================================
# ENHANCED SYSTEM INFO SCRIPT
# ============================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    '' \
    'RED="\033[0;31m"' \
    'GREEN="\033[0;32m"' \
    'YELLOW="\033[0;33m"' \
    'BLUE="\033[0;34m"' \
    'MAGENTA="\033[0;35m"' \
    'CYAN="\033[0;36m"' \
    'WHITE="\033[1;37m"' \
    'RESET="\033[0m"' \
    '' \
    '# Get system information' \
    'HOSTNAME=$(hostname)' \
    'UPTIME=$(uptime -p | sed "s/up //')'"'" \
    'CPU_CORES=$(nproc)' \
    'MEM_TOTAL=$(free -h | awk "/Mem:/ {print \$2}")' \
    'MEM_USED=$(free -h | awk "/Mem:/ {print \$3}")' \
    'DISK_TOTAL=$(df -h /home/container 2>/dev/null | tail -1 | awk '\''{print $2}'\'')' \
    'DISK_USED=$(df -h /home/container 2>/dev/null | tail -1 | awk '\''{print $3}'\'')' \
    'DISK_PERCENT=$(df -h /home/container 2>/dev/null | tail -1 | awk '\''{print $5}'\'')' \
    '' \
    '# Get IP addresses' \
    'PUBLIC_IP=$(curl -s https://api.ipify.org 2>/dev/null || echo "N/A")' \
    'LOCAL_IP=$(hostname -I | awk '\''{print $1}'\'' 2>/dev/null || echo "N/A")' \
    '' \
    '# Get location info' \
    'if [ "$PUBLIC_IP" != "N/A" ]; then' \
    '    LOCATION=$(curl -s "https://ipapi.co/${PUBLIC_IP}/json/" 2>/dev/null | jq -r '\''.city + ", " + .region + ", " + .country_name'\'' 2>/dev/null || echo "Unknown")' \
    '    ISP=$(curl -s "https://ipapi.co/${PUBLIC_IP}/org/" 2>/dev/null || echo "Unknown")' \
    'else' \
    '    LOCATION="Unknown"' \
    '    ISP="Unknown"' \
    'fi' \
    '' \
    '# Check VNC status' \
    'if pgrep -f Xtigervnc > /dev/null; then' \
    '    VNC_STATUS="${GREEN}🟢 Running${RESET}"' \
    'else' \
    '    VNC_STATUS="${RED}🔴 Stopped${RESET}"' \
    'fi' \
    '' \
    '# Check Minecraft server' \
    'if pgrep -f bedrock_server > /dev/null; then' \
    '    MC_STATUS="${GREEN}🟢 Running${RESET}"' \
    'else' \
    '    MC_STATUS="${RED}🔴 Stopped${RESET}"' \
    'fi' \
    '' \
    'clear' \
    'echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"' \
    'echo -e "${CYAN}║${RESET}     ${WHITE}VNC Desktop Container - Office & Development Suite${RESET}         ${CYAN}║${RESET}"' \
    'echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"' \
    'echo ""' \
    'echo -e "${GREEN}📊 System Information${RESET}"' \
    'echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"' \
    'echo -e "   Hostname:    ${YELLOW}${HOSTNAME}${RESET}"' \
    'echo -e "   Uptime:      ${YELLOW}${UPTIME}${RESET}"' \
    'echo -e "   CPU:         ${YELLOW}${CPU_CORES} cores${RESET}"' \
    'echo -e "   Memory:      ${YELLOW}${MEM_USED} / ${MEM_TOTAL}${RESET}"' \
    'echo -e "   Disk:        ${YELLOW}${DISK_USED} / ${DISK_TOTAL} (${DISK_PERCENT})${RESET}"' \
    'echo ""' \
    'echo -e "${GREEN}🌐 Network Information${RESET}"' \
    'echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"' \
    'echo -e "   Public IP:   ${YELLOW}${PUBLIC_IP}${RESET}"' \
    'echo -e "   Local IP:    ${YELLOW}${LOCAL_IP}${RESET}"' \
    'echo -e "   Location:    ${YELLOW}${LOCATION}${RESET}"' \
    'echo -e "   ISP:         ${YELLOW}${ISP}${RESET}"' \
    'echo ""' \
    'echo -e "${GREEN}🎮 Services Status${RESET}"' \
    'echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"' \
    'echo -e "   VNC Desktop:        ${VNC_STATUS}"' \
    'echo -e "   Minecraft Server:   ${MC_STATUS}"' \
    'echo ""' \
    'echo -e "${GREEN}🖥️ Desktop Commands${RESET}"' \
    'echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"' \
    'echo -e "   ${CYAN}desktop [port]${RESET}       - Start VNC Desktop (default: 5901)"' \
    'echo -e "   ${CYAN}stop-desktop${RESET}         - Stop VNC Desktop"' \
    'echo -e "   ${CYAN}list-desktop${RESET}         - List active VNC sessions"' \
    'echo -e "   ${CYAN}restart-desktop${RESET}      - Restart VNC Desktop"' \
    'echo ""' \
    'echo -e "${GREEN}🎮 Minecraft Commands${RESET}"' \
    'echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"' \
    'echo -e "   ${CYAN}start-mc [port]${RESET}      - Start Minecraft Bedrock (default: 19132)"' \
    'echo ""' \
    'echo -e "${GREEN}📦 Installed Applications${RESET}"' \
    'echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"' \
    'echo -e "   • ${YELLOW}Firefox Browser${RESET}               • ${YELLOW}Rclone Cloud Sync${RESET}"' \
    'echo -e "   • ${YELLOW}WPS Office Suite${RESET}              • ${YELLOW}Git & Git LFS${RESET}"' \
    'echo -e "   • ${YELLOW}Node.js $(node --version 2>/dev/null || echo "N/A")${RESET}              • ${YELLOW}Python $(python --version 2>&1 | awk '\''{print $2}'\'')${RESET}"' \
    'echo -e "   • ${YELLOW}Go $(go version 2>/dev/null | awk '\''{print $3}'\'' | sed '\''s/go//'\'')${RESET}                 • ${YELLOW}Bun $(bun --version 2>/dev/null || echo "N/A")${RESET}"' \
    'echo ""' \
    'echo -e "${GREEN}🔧 Useful Commands${RESET}"' \
    'echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"' \
    'echo -e "   ${CYAN}neofetch${RESET}             - System information"' \
    'echo -e "   ${CYAN}htop${RESET}                 - Process monitor"' \
    'echo -e "   ${CYAN}rclone config${RESET}        - Configure cloud storage"' \
    'echo ""' \
    > /usr/local/bin/show-info && \
    chmod +x /usr/local/bin/show-info

# Custom Bashrc with enhanced info
RUN printf '%s\n' \
    'alias ll="ls -alh --color=auto"' \
    'alias info="show-info"' \
    'export PS1="\[\033[1;36m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "' \
    '' \
    'if [ "$SHLVL" = "1" ]; then' \
    '    show-info' \
    'fi' \
    > /etc/bash.bashrc.custom && \
    cat /etc/bash.bashrc.custom >> /etc/bash.bashrc && \
    rm /etc/bash.bashrc.custom

# Default index.js
RUN printf '%s\n' \
    'console.log("╔═══════════════════════════════════════════════════════╗");' \
    'console.log("║   VNC Desktop Container Ready!                        ║");' \
    'console.log("╚═══════════════════════════════════════════════════════╝");' \
    'console.log("");' \
    'console.log("🖥️  Start Desktop:    desktop 5901");' \
    'console.log("🎮  Start Minecraft:  start-mc 19132");' \
    'console.log("📊  System Info:      show-info");' \
    'console.log("");' \
    > /home/container/index.js && \
    chmod 644 /home/container/index.js

# Entrypoint Script (Enhanced)
RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    '' \
    '# Change to container directory' \
    'cd /home/container || exit 1' \
    '' \
    '# Setup user identity with NSS wrapper' \
    'export USER_ID=$(id -u)' \
    'export GROUP_ID=$(id -g)' \
    'export USER_NAME=${USER:-container}' \
    '' \
    'echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Container User:/home/container:/bin/bash" > /tmp/passwd' \
    'echo "${USER_NAME}:x:${GROUP_ID}:" > /tmp/group' \
    '' \
    'export LD_PRELOAD=libnss_wrapper.so' \
    'export NSS_WRAPPER_PASSWD=/tmp/passwd' \
    'export NSS_WRAPPER_GROUP=/tmp/group' \
    '' \
    '# Create symlinks for all tools' \
    'ln -sf /usr/bin/node /usr/local/bin/node 2>/dev/null || true' \
    'ln -sf /usr/bin/npm /usr/local/bin/npm 2>/dev/null || true' \
    'ln -sf /usr/bin/npx /usr/local/bin/npx 2>/dev/null || true' \
    'ln -sf /usr/bin/yarn /usr/local/bin/yarn 2>/dev/null || true' \
    'ln -sf /usr/bin/pnpm /usr/local/bin/pnpm 2>/dev/null || true' \
    'ln -sf /usr/local/go/bin/go /usr/local/bin/go 2>/dev/null || true' \
    'ln -sf /usr/bin/python3 /usr/local/bin/python 2>/dev/null || true' \
    'ln -sf /usr/bin/pip3 /usr/local/bin/pip 2>/dev/null || true' \
    '' \
    '# Setup runtime directories' \
    'mkdir -p /tmp/runtime-container /home/container/.vnc' \
    'chmod 700 /tmp/runtime-container /home/container/.vnc' \
    '' \
    '# Export environment variables' \
    'export HOME=/home/container' \
    'export XDG_RUNTIME_DIR=/tmp/runtime-container' \
    'export VNC_PASSWORD=${VNC_PASSWORD:-${RDP_PASSWORD:-admin123}}' \
    'export DISPLAY=:1' \
    '' \
    '# Show initial banner' \
    'show-info' \
    '' \
    '# Create default index.js if not exists' \
    'if [ ! -f "/home/container/index.js" ]; then' \
    '    echo "// VNC Desktop Container" > /home/container/index.js' \
    '    echo "console.log(\"Use: desktop 5901 or start-mc 19132\");" >> /home/container/index.js' \
    'fi' \
    '' \
    '# Start bash shell' \
    'exec /bin/bash' \
    > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set ownership
RUN chown -R 1000:1000 /home/container

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
