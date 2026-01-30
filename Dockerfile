FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ============================================
# 1. Dependencias base de Ubuntu + SSH Server
# ============================================
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
    && rm -rf /var/lib/apt/lists/*

# Configurar locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ============================================
# 2. Crear usuario lautaro con sudo
# ============================================
RUN useradd -m -s /bin/bash lautaro \
    && echo 'lautaro:lautaro' | chpasswd \
    && usermod -aG sudo lautaro \
    && echo 'lautaro ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# ============================================
# 3. Configurar SSH
# ============================================
RUN mkdir -p /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ============================================
# 4. Instalar OLLAMA (IA Model Runner)
# ============================================
# Instalamos Ollama globalmente
RUN curl -fsSL https://ollama.com/install.sh | sh

# Configurar variable para que Ollama escuche en todas las interfaces (0.0.0.0)
ENV OLLAMA_HOST=0.0.0.0

# ============================================
# 5. Instalar Homebrew como usuario lautaro
# ============================================
USER lautaro
WORKDIR /home/lautaro

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ============================================
# 6. Instalar paquetes con Brew
# ============================================
RUN brew install \
    zsh \
    starship \
    zellij \
    neovim \
    lazygit \
    lsd \
    bat \
    fd \
    fzf \
    zoxide \
    atuin \
    carapace \
    go \
    zsh-autocomplete \
    zsh-syntax-highlighting \
    zsh-autosuggestions

# ============================================
# 7. Instalar fnm y Bun
# ============================================
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "/home/lautaro/.local/share/fnm" --skip-shell
RUN curl -fsSL https://bun.sh/install | bash

# ============================================
# 8. Copiar dotfiles y script de arranque
# ============================================
# Crear directorios
RUN mkdir -p /home/lautaro/.config/nvim \
    && mkdir -p /home/lautaro/.config/lazygit \
    && mkdir -p /home/lautaro/.config/zellij \
    && mkdir -p /home/lautaro/.config/starship

# Copiar configs
USER root
COPY --chown=lautaro:lautaro nvim/ /home/lautaro/.config/nvim/
COPY --chown=lautaro:lautaro lazygit/ /home/lautaro/.config/lazygit/
COPY --chown=lautaro:lautaro zellij/ /home/lautaro/.config/zellij/
COPY --chown=lautaro:lautaro starship.toml /home/lautaro/.config/starship.toml
COPY --chown=lautaro:lautaro .zshrc /home/lautaro/.zshrc

# Copiar y dar permisos al entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ============================================
# 9. Configuración final
# ============================================
RUN chsh -s /home/linuxbrew/.linuxbrew/bin/zsh lautaro

USER lautaro
ENV SHELL=/home/linuxbrew/.linuxbrew/bin/zsh
ENV STARSHIP_CONFIG=/home/lautaro/.config/starship.toml

USER root
# 22: SSH, 8080: API GO, 11434: OLLAMA API
EXPOSE 22
EXPOSE 8080
EXPOSE 11434

# Usar el script personalizado
CMD ["/entrypoint.sh"]
