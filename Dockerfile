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
    && rm -rf /var/lib/apt/lists/*

# Configurar locales (necesario para algunas herramientas)
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
# 4. Instalar Homebrew como usuario lautaro
# ============================================
USER lautaro
WORKDIR /home/lautaro

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ============================================
# 5. Instalar paquetes con Brew
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
# 6. Instalar fnm (Fast Node Manager)
# ============================================
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "/home/lautaro/.local/share/fnm" --skip-shell

# ============================================
# 7. Instalar Bun
# ============================================
RUN curl -fsSL https://bun.sh/install | bash

# ============================================
# 8. Copiar dotfiles a sus ubicaciones
# ============================================
# Crear directorios de config
RUN mkdir -p /home/lautaro/.config/nvim \
    && mkdir -p /home/lautaro/.config/lazygit \
    && mkdir -p /home/lautaro/.config/zellij \
    && mkdir -p /home/lautaro/.config/starship

# Copiar configs (como root para tener permisos, luego chown)
USER root
COPY --chown=lautaro:lautaro nvim/ /home/lautaro/.config/nvim/
COPY --chown=lautaro:lautaro lazygit/ /home/lautaro/.config/lazygit/
COPY --chown=lautaro:lautaro zellij/ /home/lautaro/.config/zellij/
COPY --chown=lautaro:lautaro starship.toml /home/lautaro/.config/starship.toml
COPY --chown=lautaro:lautaro .zshrc /home/lautaro/.zshrc

# ============================================
# 9. Cambiar shell por defecto a Zsh
# ============================================
RUN chsh -s /home/linuxbrew/.linuxbrew/bin/zsh lautaro

# ============================================
# 10. Volver a usuario lautaro y configurar entorno
# ============================================
USER lautaro
WORKDIR /home/lautaro

# Variables de entorno para que todo funcione
ENV SHELL=/home/linuxbrew/.linuxbrew/bin/zsh
ENV STARSHIP_CONFIG=/home/lautaro/.config/starship.toml

# ============================================
# Exponer SSH y puerto para API
# ============================================
USER root
EXPOSE 22
EXPOSE 8080

# Iniciar SSH
CMD ["/usr/sbin/sshd", "-D"]
