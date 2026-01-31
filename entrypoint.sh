#!/bin/bash

# Iniciar SSH en background
echo "🔒 Iniciando SSH Server..."
/usr/sbin/sshd

# Iniciar Ollama en background (sin descargar modelos automáticamente)
echo "🦙 Iniciando Ollama Server..."
ollama serve &

# Mantener el contenedor vivo
echo "🚀 Todo listo. Servidor SSH y Ollama corriendo."
echo "ℹ️  Para instalar modelos: ollama pull <modelo>"
tail -f /dev/null
