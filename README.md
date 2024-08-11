<p align="center">
	<a href="https://github.com/NoCrypt/migu">
		<img src="./common/public/logo_filled.png" width="250">
	</a>
</p>
<h1 align="center"><b>Migu</b></h1>

<h4 align="center"><b>Stream anime torrents, real-time with no waiting for downloads</b></h4>

**Migu** is a fork of [Miru](https://github.com/ThaUnknown/miru/) that focused on better **mobile** experience with added features and polished the experience by a mile.

## **Features**

Includes all original Miru features, plus:

- Toggleable AMOLED theme
- Optional Discord Rich Presence
- Optional Auto-update
- Free APK download on GitHub Releases
- Split Android builds by CPU architecture
- Auto-update with automatic CPU architecture selection
- Independent seeding speed control
- Close button on miniplayer
- Miniplayer doesn’t load on startup
- Swipe gestures for brightness and volume control on Android
- Scroll wheel for volume control on PC
- Customizable seek duration
- Proper back button functionality on Android
- Redesigned Android navigation bar for improved usability
- Correctly implemented fullscreen mode on Android
- Safe area padding and margin adjustments on Android to avoid overlap with the status bar
- Imported Default Extension and RSS feed settings from PC to Android
- Auto fullscreen video playback on Android
- Scrollable RSS feed for more anime visibility on Android
- Double-tap to seek on Android
- Default seek duration set to 5 seconds
- Volume and brightness indicators for swipe and scroll gestures
- Torrent sorting by size (+seeders) to reduce bandwidth usage
- Default new release RSS set to "ASW" to minimize bandwidth usage
- Double-click back button to exit
- Moved toast close button to the bottom for better reachability on Android
- Disabled smooth scrolling by default due to poor performance on my device

## **Building and Development**

<sub>[~~*dont.*~~](https://github.com/ThaUnknown/miru/#:~:text=Building%20and%20Development-,dont,-Dependencies%3A)</sub>

<u>***Please do! I highly encourage this!***</u>

### Requirements
- PNPM (or any package manager)
- NodeJS 20+
- Docker (with WSL support if you're on Windows)
- ADB
- Android Studio (SDK 34)
- Java 21 (JDK)

### Building for PC (Electron)
1. Navigate to the Electron directory:
   ```bash
   cd electron
   ```
2. Install dependencies:
   ```bash
   pnpm install
   ```
3. Development:
   ```bash
   pnpm start
   ```
4. Release:
   ```bash
   pnpm build
   ```

#### Build Flatpak
1. Please do all steps listed in [Building for PC (Electron)](#building-for-pc-electron)

2. Install flatpak, flathub remote and flatpak-builder (Ubuntu instructions)
   ```bash
	 sudo apt update
	 sudo apt install flatpak
	 flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	 sudo apt install flatpak-builder
	 ```

3. Build the flatpak
   ```bash
	 flatpak-builder --force-clean build-dir --install-deps-from=flathub --repo=repo ../flatpak/com.github.nocrypt.migu.yaml # must execute from the electron directory
	 ```
4. Install the built flatpak (optional)
	 ```bash
	 flatpak-builder --user --install --force-clean build-dir --install-deps-from=flathub --repo=repo ../flatpak/com.github.nocrypt.migu.yaml
	 ```
5. Bundle Migu into a .flatpak (optional)
	 ```bash
	 flatpak build-bundle repo path/to/com.github.nocrypt.migu.flatpak com.github.nocrypt.migu # replace path/to/ with your desired output path
	 ```

### Building for Android (Capacitor)
1. Navigate to the Capacitor directory:
   ```bash
   cd capacitor
   ```
2. Install dependencies:
   ```bash
   pnpm install
   ```
3. Check what's missing:
   ```bash
   pnpm exec cap doctor
   ```
4. (First time only) Build native code:
   - Windows:
     ```bash
     pnpm build:native-win
     ```
   - Linux:
     ```bash
     pnpm build:native
     ```
5. (Optional) Generate assets (if built-in forked capacitor/assets doesn’t work):
   ```bash
   pnpm dlx @capacitor/assets generate --iconBackgroundColor #20a2ff --iconBackgroundColorDark #20a2ff --splashBackgroundColor #20a2ff --splashBackgroundColorDark #20a2ff --android
   ```
6. Open the Android project:
   ```bash
   pnpm exec cap open android
   ```
7. Connect your phone with ADB.
8. Development:
   ```bash
   pnpm dev:start
   ```
9. Release:
   ```bash
   pnpm build:app
   ```

## License

This project acknowledges and complies with the GPLv3 license.
