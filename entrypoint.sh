#!/bin/bash

# Iniciar SSH en background
echo "🔒 Iniciando SSH Server..."
/usr/sbin/sshd

# Mantener el contenedor vivo
echo "🚀 Todo listo. Servidor SSH corriendo."
echo "ℹ️  Para instalar Ollama, ejecutar: /usr/local/bin/install_ollama.sh"
tail -f /dev/null
