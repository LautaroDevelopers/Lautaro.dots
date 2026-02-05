# Android Development in Neovim - Quick Reference

## 🔧 Initial Setup

1. **Install Required Tools**:
   ```bash
   ~/.config/nvim/android-setup.sh
   ```

2. **Reload Shell**:
   ```bash
   source ~/.zshrc
   ```

3. **Install Neovim Plugins**:
   - Open Neovim: `nvim`
   - Run: `:Lazy sync`
   - Run: `:Mason` and install:
     - `jdtls` (Java Language Server)
     - `kotlin-language-server`
     - `java-debug-adapter`
     - `java-test`

## ⌨️  Key Bindings (in Neovim)

### Build & Run
- `<leader>ab` - Build Debug (assembleDebug)
- `<leader>ar` - Install & Run Debug on connected device
- `<leader>aR` - Build Release (assembleRelease)
- `<leader>ac` - Clean project

### ADB Commands
- `<leader>ad` - List connected devices
- `<leader>al` - View Logcat (all logs)
- `<leader>aL` - View Logcat (errors only)
- `<leader>as` - Open ADB shell

### Debugging
- `<F5>` - Start/Continue debugging
- `<F10>` - Step over
- `<F11>` - Step into
- `<F12>` - Step out
- `<leader>db` - Toggle breakpoint
- `<leader>dr` - Open REPL

## 📱 Common Workflows

### Create New Android Project
```bash
# Using Android Studio command line (if installed)
android create project --target android-33 --name MyApp --path ./MyApp --activity MainActivity --package com.example.myapp

# OR clone a template
git clone https://github.com/android/sunflower
```

### Build & Install
```bash
# From Neovim:
<leader>ar

# From terminal:
./gradlew installDebug
```

### View Logs
```bash
# From Neovim:
<leader>al

# From terminal:
adb logcat

# Filter by tag:
adb logcat -s "MyTag"

# Clear logcat:
adb logcat -c
```

### Debug on Device
```bash
# List devices
adb devices

# Install APK manually
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Uninstall
adb uninstall com.example.myapp

# Take screenshot
adb shell screencap /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Record screen
adb shell screenrecord /sdcard/demo.mp4
```

## 🐛 Debugging in Neovim

1. **Enable debugging in your app**:
   Add to `app/build.gradle`:
   ```gradle
   android {
       buildTypes {
           debug {
               debuggable true
           }
       }
   }
   ```

2. **Start debug server**:
   ```bash
   ./gradlew installDebug
   adb shell am set-debug-app -w com.example.myapp
   ```

3. **In Neovim**:
   - Set breakpoints: `<leader>db`
   - Start debugger: `<F5>`
   - Select "Debug (Attach) - Remote"

## 📦 Gradle Tasks

```bash
# List all tasks
./gradlew tasks

# Build variants
./gradlew assembleDebug
./gradlew assembleRelease

# Run tests
./gradlew test
./gradlew connectedAndroidTest

# Clean
./gradlew clean

# Check dependencies
./gradlew dependencies

# Lint check
./gradlew lint
```

## 🚀 Emulator

```bash
# List available AVDs
emulator -list-avds

# Start emulator
emulator -avd Pixel_8_API_35 &

# Start with writable system
emulator -avd Pixel_8_API_35 -writable-system &
```

## 💡 Tips

1. **Faster Builds**: Add to `gradle.properties`:
   ```properties
   org.gradle.daemon=true
   org.gradle.parallel=true
   org.gradle.caching=true
   kotlin.incremental=true
   ```

2. **Hot Reload**: Not available like in Flutter, but you can use:
   - Gradle's `--continuous` flag
   - Android's Apply Changes (requires more setup)

3. **LSP Features**:
   - Auto-import: `<leader>ca` (Code Action)
   - Go to definition: `gd`
   - Find references: `gr`
   - Rename symbol: `<leader>cr`

4. **XML Layout Preview**: Use external tools:
   - Android Studio (just for preview)
   - Online tools like https://appetize.io

## 🔍 Troubleshooting

### LSP not working
```vim
:LspInfo
:Mason
```

### Gradle sync issues
```bash
./gradlew --refresh-dependencies
./gradlew clean build --no-daemon
```

### ADB not detecting device
```bash
adb kill-server
adb start-server
adb devices

# If using USB, check permissions
lsusb
# Add udev rules if needed
```

### Java version conflicts
```bash
archlinux-java status
sudo archlinux-java set java-17-openjdk
```

## 📚 Resources

- [Android Developer Docs](https://developer.android.com)
- [Gradle Build Tool](https://gradle.org)
- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
- [ADB Commands](https://developer.android.com/tools/adb)
