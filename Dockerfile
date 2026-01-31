FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ============================================
# 1. Dependencias base y herramientas de APT
# ============================================
# Instalamos todo lo que esté en repo oficial para ahorrar espacio
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    tzdata \
    ca-certificates \
    build-essential \
    procps \
    file \
    locales \
    unzip \
    zstd \
    zsh \
    bat \
    fd-find \
    ripgrep \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# Configurar locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Alias para bat y fd (en ubuntu se llaman batcat y fdfind)
RUN ln -s /usr/bin/batcat /usr/local/bin/bat && \
    ln -s /usr/bin/fdfind /usr/local/bin/fd

# ============================================
# 2. Instalación MANUAL de Herramientas (Sin Homebrew)
# ============================================

# --- Neovim (AppImage o Tarball es más ligero) ---
RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz && \
    tar -C /usr/local -xzf /tmp/nvim.tar.gz && \
    ln -s /usr/local/nvim-linux64/bin/nvim /usr/local/bin/nvim && \
    rm /tmp/nvim.tar.gz

# --- Zellij ---
RUN wget https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz -O /tmp/zellij.tar.gz && \
    tar -C /usr/local/bin -xzf /tmp/zellij.tar.gz && \
    rm /tmp/zellij.tar.gz && \
    chmod +x /usr/local/bin/zellij

# --- LSD (Ls Deluxe) ---
RUN wget https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd_1.0.0_amd64.deb -O /tmp/lsd.deb && \
    dpkg -i /tmp/lsd.deb && \
    rm /tmp/lsd.deb

# --- Go 1.23 ---
RUN wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# --- Starship ---
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- Ollama ---
RUN curl -fsSL https://ollama.com/install.sh | sh
ENV OLLAMA_HOST=0.0.0.0

# ============================================
# 3. Crear usuario lautaro
# ============================================
RUN useradd -m -s /bin/zsh lautaro \
    && echo 'lautaro:lautaro' | chpasswd \
    && usermod -aG sudo lautaro \
    && echo 'lautaro ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# ============================================
# 4. Configurar SSH
# ============================================
RUN mkdir -p /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ============================================
# 5. Configuración de Usuario (Scripts que no requieren root)
# ============================================
USER lautaro
WORKDIR /home/lautaro

# --- Zoxide, Atuin, Carapace (Scripts de install) ---
RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
RUN curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh
RUN curl -sS https://raw.githubusercontent.com/rsteube/carapace-bin/main/install.sh | bash -s -- -d ~/.local/bin

# --- FNM & Bun ---
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "/home/lautaro/.local/share/fnm" --skip-shell
RUN curl -fsSL https://bun.sh/install | bash

# --- Plugins ZSH (Manual clone porque no tenemos brew) ---
RUN mkdir -p ~/.zsh/plugins && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/plugins/zsh-autocomplete

# ============================================
# 6. Copiar Dotfiles
# ============================================
USER root
# Crear directorios
RUN mkdir -p /home/lautaro/.config/nvim \
    && mkdir -p /home/lautaro/.config/lazygit \
    && mkdir -p /home/lautaro/.config/zellij \
    && mkdir -p /home/lautaro/.config/starship

# Copiar configs
COPY --chown=lautaro:lautaro nvim/ /home/lautaro/.config/nvim/
COPY --chown=lautaro:lautaro lazygit/ /home/lautaro/.config/lazygit/
COPY --chown=lautaro:lautaro zellij/ /home/lautaro/.config/zellij/
COPY --chown=lautaro:lautaro starship.toml /home/lautaro/.config/starship.toml
COPY --chown=lautaro:lautaro .zshrc /home/lautaro/.zshrc

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ============================================
# 7. Final
# ============================================
USER lautaro
ENV SHELL=/bin/zsh
ENV STARSHIP_CONFIG=/home/lautaro/.config/starship.toml
# Ajustamos PATH para incluir lo que instalamos manualmente
ENV PATH="/home/lautaro/.local/bin:/home/lautaro/.cargo/bin:${PATH}"

USER root
EXPOSE 22
EXPOSE 8080
EXPOSE 11434

CMD ["/entrypoint.sh"]
