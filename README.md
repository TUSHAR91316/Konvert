# Konvert - Advanced File Management & Conversion Tool

<p align="center">
  <img src="assets/images/readme_icon.png" width="150" alt="Konvert Logo">
</p>

<p align="center">
  <a href="https://konvert-website.vercel.app/">
    <img src="https://img.shields.io/badge/Official-Website-blue?style=for-the-badge&logo=vercel" alt="Official Website">
  </a>
  <a href="https://www.amazon.in/PrivateByte-Labs-Konvert/dp/B0GDRZLHZ7/">
    <img src="https://img.shields.io/badge/Get_it_on-Amazon_Appstore-orange?style=for-the-badge&logo=amazon" alt="Available on Amazon Appstore">
  </a>
</p>

<p align="center">
  <img src="https://github.com/TUSHAR91316/converter_app/actions/workflows/flutter_ci.yml/badge.svg?branch=main" alt="Flutter CI">
  <img src="https://github.com/TUSHAR91316/converter_app/actions/workflows/backend_ci.yml/badge.svg?branch=main" alt="Backend CI">
</p>

Konvert is a hybrid, secure, and powerful mobile application designed to handle file conversions and compression with a focus on **User Privacy** and **Security**. Unlike typical web tools, Konvert processes sensitive files (like Images) locally on your device whenever possible.

## 🌟 Key Features

### 1. 🔄 Smart File Conversion
- **Hybrid Engine**: Automatically chooses the best way to convert your file.
    - **Local**: Images to PDF (Processed entirely on-device).
    - **Self-Hosted**: complex docs (DOCX, XLSX, PPTX) are handled securely by your own personal backend (LibreOffice).
- **Supported Formats**:
    - **Images**: JPG, PNG, WEBP, HEIC ➡️ PDF
    - **Documents**: DOC, DOCX, TXT, RTF, ODT, HTML ➡️ PDF
    - **Office**: XLS, XLSX, PPT, PPTX ➡️ PDF

### 2. 📉 Compression Studio
- **Compress Images**: Reduce image size efficiently.
    - **Quality Mode**: Reduce by percentage (e.g., 80% quality).
    - **Target Size Mode**: Specify your limit (e.g., "Max 500 KB"), and the app auto-optimizes.
- **Shrink Docs**: (Coming Soon) Optimize PDF file sizes.

### 3. 🛡️ Advanced Security
- **Auto-Scan Integration**: Connect your **VirusTotal API Key** in Settings.
- **Automatic Safety**: If enabled, files are strictly scanned for malware *before* any conversion starts.
- **Privacy First**: We don't store your files. Self-Hosted conversions are temporary and deleted immediately after processing.

### 4. 📜 History & Management
- **Conversion History**: Keep track of all your past tasks.
- **Offline Access**: History is stored locally on your device.
- **Guest Mode**: Use the app without an account (limitations apply).

---

## 🆚 Konvert vs. Web Converters

Why download Konvert? It offers a **Hybrid** advantage:

| Feature | 🚀 Konvert App | 🌐 Typical Web Converter |
| :--- | :--- | :--- |
| **Images** (Privacy) | **100% Offline**: Processed on your phone. No upload. | **Online**: Must upload photos to server. |
| **Documents** (Docs/PPT) | **Self-Hosted**: Sent to your personal server, processed, then **instantly deleted**. | **Unknown**: Files often stored for hours/days. |
| **Security** | **VirusTotal Auto-Scan** checks files before upload. | No virus scanning. |
| **Speed** | **Instant** for local tools (Images). | **Slow**: Dependent on upload speed. |
| **History** | **Local Log**: Keeps your history private on-device. | **None**: Data lost after closing tab. |
| **Ads** | **Ad-Free** experience. | **Cluttered**: Full of ads/popups. |

> **Note**: Document conversion (DOCX, PPTX) requires an internet connection to reach our secure helper backend. Image tools work completely offline.

---

## 🔧 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Python (FastAPI) + LibreOffice (in Docker)
- **Security**: VirusTotal API + Flutter Secure Storage
- **Tools**: `flutter_image_compress`, `file_picker`, `firebase_auth`
- **CI/CD**: GitHub Actions (Automated Testing & Building)

## 🔄 CI/CD Pipeline

This project uses **GitHub Actions** to enjoy a modern DevOps workflow.

| Workflow | Status | Description |
| :--- | :--- | :--- |
| **Flutter CI** | ![Flutter CI](https://github.com/TUSHAR91316/converter_app/actions/workflows/flutter_ci.yml/badge.svg?branch=main) | Automatically lints, tests, and builds the Android APK on every push. **Artifacts (APKs) are downloadable** from the Actions tab. |
| **Backend CI** | ![Backend CI](https://github.com/TUSHAR91316/converter_app/actions/workflows/backend_ci.yml/badge.svg?branch=main) | Lints Python code and verifies the Docker build to prevent deployment errors. |

## 🚀 Getting Started!

This application relies on a local Docker backend securely exposed via an ngrok Tunnel with a static domain, eliminating cloud hosting costs while retaining global accessibility for your mobile app.

1. **Download the Backend Files**
   Because Konvert is closed-source, you can download the backend server files (`backend.zip`) directly from our [Public GitHub Releases Page](https://github.com/TUSHAR91316/Konvert-Website/releases). Extract this `backend.zip` folder to your computer.
2. **Run the Backend (Docker)**:
   Navigate to the extracted `backend/` folder and run the container locally on port 8080:
   ```bash
   docker build -t converter-backend .
   docker run -d -p 8080:8080 converter-backend
   ```
3. **Start the ngrok Tunnel**:
   Expose your local backend to the internet securely using `ngrok` (with your static domain):
   ```bash
   ngrok http --domain=your-static-domain.ngrok-free.app 8080
   ```
   *Tip: If you use a personal Windows device, you can run ngrok silently by creating a `.bat` file with:*
   ```bat
   @ECHO OFF
   Start-Process ngrok -ArgumentList "http --domain=your-static-domain.ngrok-free.app 8080" -WindowStyle Hidden
   ```
4. **Configure App Settings**:
   Launch the app on your device/emulator. Navigate to the **Settings** screen inside Konvert and paste your static `.ngrok-free.app` URL into the "Backend URL" field to connect globally instantly!
   *(Note: You no longer need to edit `.env` or rebuild the APK!)*
