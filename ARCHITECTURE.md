# Konvert — System Architecture & Technical Deep Dive 🏗️

<p align="center">
  <img src="assets/images/readme_icon.png" width="120" alt="Konvert Logo">
</p>

This document provides a comprehensive, in-depth architectural breakdown of **Konvert** (v1.7.0). It covers the hybrid engine mechanics, real-time telemetry pipeline, Docker multi-container topology, and zero-trust security model.

---

## 📑 Table of Contents
1. [High-Level System Topology](#1-high-level-system-topology)
2. [Hybrid Conversion Decision Engine](#2-hybrid-conversion-decision-engine)
3. [Real-Time Telemetry & Health Monitoring](#3-real-time-telemetry--health-monitoring)
4. [Multi-Container Docker Network Topology](#4-multi-container-docker-network-topology)
5. [In-App APK Streaming & Native Installer](#5-in-app-apk-streaming--native-installer)
6. [Zero-Trust Security & Ephemeral Storage](#6-zero-trust-security--ephemeral-storage)
7. [Technology Stack Matrix](#7-technology-stack-matrix)

---

## 1. High-Level System Topology

```mermaid
graph TB
    subgraph Client["📱 Flutter Mobile & Desktop Client"]
        UI["UI Layer (Screens & Bento Cards)"]
        CS["ConversionService (Hybrid Dispatcher)"]
        TS["UpdateService (In-App Downloader)"]
        HS["HistoryService (SQLite DAO)"]
        AS["AuthService (Google Sign-In v7 / Firebase)"]
        CFS["ConfigService (Secure Storage / Loopback)"]
        
        subgraph OnDeviceEngines["⚡ 100% Offline Engines"]
            DartPDF["Dart pdf + printing Engine"]
            ImgCompress["flutter_image_compress"]
        end
    end

    subgraph Tunnel["🌐 Secure Ingress (Ngrok HTTPS)"]
        NgrokCloud["Ngrok Edge Cloud (*.ngrok-free.dev)"]
        NgrokContainer["Docker: backend-ngrok-1"]
    end

    subgraph HostServer["🐳 Self-Hosted Docker Backend"]
        FastAPI["FastAPI Microservice (backend-api-1 :8080)"]
        LibreOffice["Headless LibreOffice Subprocess"]
        PyPDF["pypdf Lossless Engine"]
        PsutilEngine["psutil Telemetry Monitor"]
        TmpStorage["/tmp/uploads & /tmp/outputs (Auto-Purged)"]
    end

    subgraph CloudServices["☁️ External Third-Party APIs"]
        FirebaseAuth["Firebase Auth (Android Credential Manager)"]
        Firestore["Cloud Firestore (Metadata Sync)"]
        VirusTotal["VirusTotal v3 API (32MB Scan Guard)"]
        GitHubAPI["GitHub Releases API (v1.7.0 Asset Server)"]
    end

    %% Client Internal Flow
    UI --> CS
    UI --> TS
    UI --> AS
    UI --> CFS
    CS --> DartPDF
    CS --> ImgCompress
    CS --> HS
    
    %% Client to Network
    CS -- "HTTP Multipart Upload / Download" --> NgrokCloud
    UI -- "GET /health/details" --> NgrokCloud
    TS -- "GET /releases/latest" --> GitHubAPI
    AS -- "ID Token Verification" --> FirebaseAuth
    CS -- "SHA256 File Scan" --> VirusTotal
    
    %% Tunnel to Backend
    NgrokCloud --> NgrokContainer
    NgrokContainer -- "host.docker.internal:8080" --> FastAPI
    
    %% Backend Internal Processing
    FastAPI --> LibreOffice
    FastAPI --> PyPDF
    FastAPI --> PsutilEngine
    FastAPI --> TmpStorage
```

---

## 2. Hybrid Conversion Decision Engine

Konvert operates on a **Fail-Safe Hybrid Pipeline**. Offline-capable tasks run directly on the device, while complex office document rendering and lossless multi-PDF merges are processed on the user's private Docker microservice with instant on-device fallbacks:

```mermaid
flowchart TD
    Start(["User initiates conversion / merge"]) --> DetectType{"Operation Type?"}

    %% Image to PDF
    DetectType -- "Images → PDF" --> OfflineImgPDF["On-Device Dart pdf Engine"]
    OfflineImgPDF --> SaveLocal["Save to Local Device Storage"]
    SaveLocal --> LogHistory["Log Entry in SQLite History"]
    LogHistory --> Done(["Conversion Complete 🎉"])

    %% Image Compression
    DetectType -- "Image Compression" --> LocalCompress["flutter_image_compress (Native)"]
    LocalCompress --> SaveLocal

    %% Multi-PDF Merge
    DetectType -- "Multi-PDF Merge" --> PingCheck{"Health Check Docker Backend?"}
    PingCheck -- "Online (200 OK)" --> BackendMerge["Upload to /merge-pdfs via Dio"]
    BackendMerge --> ValidatePDF{"Is Output Valid PDF (>2KB)?"}
    ValidatePDF -- "Yes" --> DownloadMerge["Stream Download to Storage"]
    DownloadMerge --> SaveLocal
    
    ValidatePDF -- "Error Payload" --> OfflineMergeFallback["Fallback: On-Device pdf + printing Raster Merge"]
    PingCheck -- "Offline / Timeout" --> OfflineMergeFallback
    OfflineMergeFallback --> SaveLocal

    %% Document to PDF (Word/Excel/PPT/ODT)
    DetectType -- "Office Docs → PDF\n(DOCX, XLSX, PPTX, ODT)" --> CheckBackendDoc{"Backend Online?"}
    CheckBackendDoc -- "Online" --> UploadDoc["POST /convert with target_format"]
    UploadDoc --> LibreOfficeAsync["Backend: asyncio LibreOffice Execution"]
    LibreOfficeAsync --> StreamOutput["Stream Output via FileResponse"]
    StreamOutput --> CleanupDocker["BackgroundTask: Delete Server Temp Files"]
    StreamOutput --> SaveLocal
    
    CheckBackendDoc -- "Offline" --> PromptDockerError["Show Actionable Error 5001\n'Start Docker backend'"]
```

---

## 3. Real-Time Telemetry & Health Monitoring

The **System Status Bento Card** and **Telemetry Bottom Sheet** track the health, latency, and resource footprint of the Docker backend in real time:

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 User
    participant App as 📱 Konvert App (Home Screen)
    participant Dio as 🌐 Dio HTTP Client
    participant Ngrok as 🛡️ Ngrok Edge Tunnel
    participant Backend as 🐳 FastAPI Backend (:8080)
    participant OS as 💻 Host OS (psutil)

    User->>App: Tap "SYSTEM STATUS" Bento Card
    App->>App: Open _TelemetrySheet (StatefulModal)
    App->>Dio: GET /health/details<br/>Headers: {ngrok-skip-browser-warning: true}
    Note over App,Dio: Timestamp T0 Recorded (Latency Clock)
    Dio->>Ngrok: HTTPS Request (opal-...ngrok-free.dev)
    Ngrok->>Backend: Reverse Proxy -> host.docker.internal:8080
    Backend->>OS: psutil.cpu_percent(interval=0.1)
    Backend->>OS: psutil.virtual_memory()
    Backend->>OS: psutil.disk_usage('/')
    OS-->>Backend: CPU%, RAM (Used/Total MB), Disk Free GB
    Backend-->>Ngrok: 200 OK {status, cpu_percent, memory_used_mb, ...}
    Ngrok-->>Dio: JSON Payload
    Note over App,Dio: Timestamp T1 -> Latency = (T1 - T0) ms
    Dio-->>App: Parse Map<String, dynamic>
    App->>App: Animate Progress Bars (CPU %, RAM %, Disk GB, Latency ms)
    App-->>User: Display Live Telemetry Modal
```

---

## 4. Multi-Container Docker Network Topology

The backend runs as an isolated, self-healing Docker Compose network on the user's host machine:

```mermaid
graph LR
    subgraph HostNetwork["💻 Host Machine Network (Windows / macOS / Linux)"]
        HostPort["Host Port :8080"]
        
        subgraph DockerEngine["🐳 Docker Compose Network (backend_default)"]
            subgraph API_Container["Container: backend-api-1"]
                Uvicorn["Uvicorn Server (0.0.0.0:8080)"]
                FastAPIApp["FastAPI app (main.py)"]
                LibreExec["LibreOffice Headless (C++)"]
                PyPDFModule["pypdf 5.4.0 Engine"]
                PsutilModule["psutil 6.0.0 Engine"]
            end
            
            subgraph Ngrok_Container["Container: backend-ngrok-1"]
                NgrokClient["ngrok agent (ngrok/ngrok:latest)"]
            end
        end
    end

    subgraph PublicInternet["🌍 Public Internet"]
        MobileClient["📱 Mobile App Client"]
        NgrokRelay["☁️ Ngrok Cloud Infrastructure"]
    end

    %% Wiring
    Uvicorn --> FastAPIApp
    FastAPIApp --> LibreExec
    FastAPIApp --> PyPDFModule
    FastAPIApp --> PsutilModule
    API_Container -- "Exposed Port" --> HostPort
    
    NgrokClient -- "host.docker.internal:8080" --> HostPort
    NgrokClient -- "Encrypted TLS Tunnel" --> NgrokRelay
    MobileClient -- "HTTPS (ngrok-skip-browser-warning)" --> NgrokRelay
```

---

## 5. In-App APK Streaming & Native Installer

Version 1.7.0 replaces external browser redirects with a seamless streaming downloader and native Android Package Installer invocation:

```mermaid
sequenceDiagram
    autonumber
    participant App as 📱 Konvert App
    participant GH as 🐙 GitHub Releases API
    participant Stream as 📥 Dio Streaming Engine
    participant Installer as 🤖 Android PackageInstaller (open_file)

    App->>GH: GET /repos/TUSHAR91316/Konvert-Website/releases/latest
    GH-->>App: JSON {tag_name: "V1.7.0", assets: [{name: "app-release.apk", browser_download_url: "..."}]}
    App->>App: isUpdateAvailable(current, latest) -> true
    App->>App: Display _InAppUpdateDialog
    App->>Stream: Dio().download(apkUrl, tempPath/Konvert_v1.7.0.apk)
    loop Every Chunk Received
        Stream->>App: onReceiveProgress(received, total)
        App->>App: Update LinearProgressIndicator ((received/total)*100 %)
    end
    Stream-->>App: File saved to getTemporaryDirectory()
    App->>Installer: OpenFile.open(apkPath)
    Installer-->>App: Launch Native Android System Installer Prompt
```

---

## 6. Zero-Trust Security & Ephemeral Storage

Konvert enforces a **strict zero-retention policy**. Files are never retained on the server once processing terminates:

```mermaid
stateDiagram-v2
    [*] --> ClientUpload: User selects document
    ClientUpload --> Sanitization: Filename sanitized regex [^a-zA-Z0-9.-]
    Sanitization --> TempSave: Written to /tmp/uploads/{UUID}_{file}
    
    state ConversionProcess {
        TempSave --> LibreOfficeExec: Subprocess execution
        LibreOfficeExec --> OutputGeneration: Generated in /tmp/outputs/
    }
    
    state CleanupGuarantees {
        OutputGeneration --> BackgroundTaskStreaming: FileResponse streaming bytes to Client
        BackgroundTaskStreaming --> DeleteOutput: Starlette BackgroundTask triggers os.remove()
        
        LibreOfficeExec --> CrashHandler: Subprocess crash / timeout
        CrashHandler --> FinallyBlock: finally block sweeps /tmp/uploads & /tmp/outputs
        FinallyBlock --> [*]: Zero Orphaned Bytes
    }
    
    DeleteOutput --> [*]: Clean File System
```

---

## 7. Technology Stack Matrix

| Component | Technology | Version | Purpose |
|---|---|---|---|
| **Frontend Framework** | Flutter SDK | `3.38.3` | Multiplatform client UI and offline engines |
| **Dart Runtime** | Dart SDK | `3.10.x` | Modern null-safe asynchronous logic |
| **Build Toolchain** | Gradle / AGP | `8.14` / `8.11.1` | Android compilation target (compileSdk 37) |
| **Java Target** | OpenJDK | `Java 17` | Clean release builds with zero obsolete warnings |
| **Backend Framework** | FastAPI + Uvicorn | `0.115.5` / `0.32.1` | Async REST Microservice |
| **Office Conversion** | LibreOffice Headless | `7.x / 24.x` | High-fidelity document-to-PDF engine |
| **Server PDF Merger** | `pypdf` | `5.4.0` | Server-side lossless PDF page stream merger |
| **System Telemetry** | `psutil` | `6.0.0` | Real-time CPU %, RAM, and Disk inspection |
| **Ingress Tunneling** | Ngrok Docker | `latest` | Secure HTTPS static domain reverse proxy |
| **Authentication** | Google Sign-In | `7.2.0` | Android Credential Manager integration |
| **Local Database** | SQLite (`sqflite`) | `2.4.3` | Device-local history and offline logs |
| **Secure Keyring** | `flutter_secure_storage` | `9.2.4` | Encrypted theme, tokens, and backend URLs |

---

*Documented for Konvert v1.7.0+13*
