#!/bin/bash

echo "🚀 Iniciando instalación de Ollama..."

# Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Configurar variable para que Ollama escuche en todas las interfaces (0.0.0.0)
echo "export OLLAMA_HOST=0.0.0.0" >>~/.profile

echo "✅ Ollama instalado."
echo "ℹ️  Para iniciar el servidor Ollama: ollama serve &"
echo "ℹ️  Para instalar un modelo (ej: qwen2.5-coder:32b): ollama pull qwen2.5-coder:32b"
