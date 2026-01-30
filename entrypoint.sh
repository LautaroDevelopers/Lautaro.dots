#!/bin/bash

# Iniciar SSH en background
echo "🔒 Iniciando SSH Server..."
/usr/sbin/sshd

# Iniciar Ollama en background
echo "🦙 Iniciando Ollama Server..."
ollama serve &

# Esperar unos segundos a que Ollama arranque
sleep 5

# Chequear si el modelo ya existe, si no, descargarlo
MODEL="qwen2.5-coder:32b"
echo "🔍 Verificando modelo $MODEL..."

if ! ollama list | grep -q "$MODEL"; then
	echo "📥 El modelo no está. Iniciando descarga de $MODEL (Esto puede tardar dependiendo de la red de Railway)..."
	ollama pull $MODEL
	echo "✅ Modelo descargado y listo."
else
	echo "⚡ Modelo ya descargado. Listo para usar."
fi

# Mantener el contenedor vivo
echo "🚀 Todo listo. Esperando conexiones..."
tail -f /dev/null
