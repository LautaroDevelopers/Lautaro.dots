#!/bin/bash
# Android Development Setup Script for Arch Linux
# This script configures Neovim to use your existing Android Studio SDK

set -e

echo "🚀 Setting up Android Development Environment for Neovim..."
echo ""

# Check if Android SDK exists
if [ ! -d "$HOME/Android/Sdk" ]; then
    echo "❌ Android SDK not found at ~/Android/Sdk"
    echo "Please install Android Studio first or adjust the path."
    exit 1
fi

echo "✓ Found Android SDK at ~/Android/Sdk"
echo ""

# Install Java JDK (OpenJDK 21 is required for modern Gradle)
echo "📦 Installing Java JDK 21..."
sudo pacman -S --needed jdk21-openjdk

# Install Gradle
echo "📦 Installing Gradle..."
sudo pacman -S --needed gradle

# Install Kotlin (optional but recommended)
echo "📦 Installing Kotlin..."
sudo pacman -S --needed kotlin

echo ""
echo "🔧 Configuring environment variables..."

# Backup .zshrc
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# Add Android environment variables if not already present
if ! grep -q "ANDROID_HOME" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOF'

# Android Development Environment
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/emulator:$PATH
export PATH=$ANDROID_HOME/build-tools/$(ls $ANDROID_HOME/build-tools | tail -n 1):$PATH
EOF
    echo "✓ Added ANDROID_HOME to ~/.zshrc"
else
    echo "✓ ANDROID_HOME already configured"
fi

# Add JAVA_HOME if not already present
if ! grep -q "JAVA_HOME" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOF'

# Java Development Environment
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH
EOF
    echo "✓ Added JAVA_HOME to ~/.zshrc"
else
    echo "✓ JAVA_HOME already configured"
fi

# Export for current session
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/emulator:$PATH
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Installed:"
echo "   ✓ Java JDK 21"
echo "   ✓ Gradle"
echo "   ✓ Kotlin"
echo ""
echo "🔧 Environment variables configured:"
echo "   ANDROID_HOME = $HOME/Android/Sdk"
echo "   JAVA_HOME = /usr/lib/jvm/java-21-openjdk"
echo ""
echo "📝 Next steps:"
echo "1. Reload your shell:"
echo "   source ~/.zshrc"
echo ""
echo "2. Open Neovim and install plugins:"
echo "   nvim"
echo "   :Lazy sync"
echo ""
echo "3. Install LSP servers in Neovim:"
echo "   :Mason"
echo "   Install: jdtls, kotlin-language-server, java-debug-adapter"
echo ""
echo "4. Test it:"
echo "   cd ~/Work/AndroidStudio/Launcher"
echo "   nvim"
echo ""
echo "🔑 Key bindings in Neovim:"
echo "   <leader>ab - Build Debug"
echo "   <leader>ar - Install & Run on Device"
echo "   <leader>al - View Logcat"
echo "   <leader>ad - List ADB Devices"
echo ""
echo "📚 Read ~/.config/nvim/ANDROID.md for full documentation"
