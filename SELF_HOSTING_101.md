# Konvert 101: Complete Setup & Self-Hosting Guide 🚀

Welcome to Konvert! Because we take user privacy seriously, we don't rely on centralized cloud servers for document processing. Instead, **you** host your own private conversion backend. 

By following this guide, you will set up a local Docker backend on your computer that your mobile app will securely communicate with. Your documents never leave your control, and everything is instantly deleted from the server after conversion.

---

## 🛠️ Prerequisites

Before starting, verify you have the following installed on your host machine:
1. **Docker Desktop** ([Download here](https://www.docker.com/products/docker-desktop/)) - Required to run the containerized backend.
2. **Active Internet Connection** - Required to route traffic from your mobile device to your home server.

---

## 🌐 Step 1: Claim Your Free Static Domain (Ngrok)

To allow the Konvert mobile app to reach your home machine securely over cellular data or external Wi-Fi, you need a public URL. We use **Ngrok** to create a secure, encrypted HTTPS tunnel.

1. Sign up for a free [ngrok account](https://dashboard.ngrok.com/).
2. Go to your Ngrok Dashboard and retrieve your **Auth Token**.
3. Go to the **Domains** section and claim your **Free Static Domain** (e.g., `fancy-otter-123.ngrok-free.app`). This domain is permanent and free!

---

## 🐳 Step 2: Deployment Methods

Choose **one** of the two methods below to spin up your backend:

### Method A: Docker Compose (Recommended & Easiest)
This method spins up both the backend API and the Ngrok tunnel inside Docker automatically. You do not need to install Ngrok on your local machine.

1. **Download the Backend Files**:
   Download the **`backend.zip`** from the [Konvert Releases Page](https://github.com/TUSHAR91316/Konvert-Website/releases) (or navigate to the `/backend` folder if you cloned the source code).
2. **Extract & Open**:
   Extract the zip file and open a Terminal / Command Prompt inside that directory.
3. **Configure Environment variables**:
   Locate `.env.example` in the folder, rename it to `.env`, and open it in a text editor. Add your credentials:
   ```env
   NGROK_AUTHTOKEN=your_actual_ngrok_auth_token_here
   NGROK_DOMAIN=fancy-otter-123.ngrok-free.app
   ```
4. **Launch the Stack**:
   Run the following command:
   ```bash
   docker-compose up -d --build
   ```
   *Your server and secure tunnel are now running in the background!*

---

### Method B: Standalone Docker (Manual / Developer Mode)
Choose this if you want to run the Docker container manually and tunnel the traffic yourself using a local Ngrok or Cloudflare installation.

1. **Build & Run the Container**:
   Open terminal in the `/backend` folder and run:
   ```bash
   # Build the image
   docker build -t konvert-backend .

   # Run the container (maps backend port 8080 to host port 8080)
   docker run -d -p 8080:8080 --name konvert-backend konvert-backend
   ```
2. **Expose the Port**:
   In a separate terminal window, use your preferred tunneling tool:
   * **Using Ngrok CLI**:
     ```bash
     ngrok http 8080 --url=fancy-otter-123.ngrok-free.app
     ```
   * **Using Cloudflare Tunnel (Alternative)**:
     ```bash
     cloudflared tunnel --url http://localhost:8080
     ```

---

## 📱 Step 3: Configure the Mobile App

Now that your personal cloud is running securely, point the Konvert app to it.

1. **Get the App**: Download and install the latest APK from the GitHub releases page.
2. **Go to Settings**: Open Konvert, go to **Settings** (or tap the System Status card on the Dashboard).
3. **Enter Backend URL**: 
   * Paste your static domain URL (including `https://`). Example: `https://fancy-otter-123.ngrok-free.app`
   * Tap **Test Connection** or save.
4. **Convert Safely!**
   You're all set! When converting Word, Excel, or PPT documents, they are sent to your tunnel, processed locally on your own computer, and wiped instantly.

---

## 🔍 Step 4: Verify Your Server Status

You can check if your server is running properly by visiting the health check URL in your web browser:
`https://fancy-otter-123.ngrok-free.app/health`

It should return a JSON response:
```json
{"status": "ok"}
```

---

## 🛠️ Troubleshooting & FAQs

### Port 8080 is already in use
If another application on your computer is using port 8080, the container will fail to start. Open `docker-compose.yml` and change the port mapping:
```yaml
ports:
  - "9090:8080" # Map host port 9090 to container port 8080
```
Update your Ngrok command/config to tunnel port `9090` instead of `8080`.

### Ngrok Browser Warning Page
When accessing the tunnel via a browser, Ngrok displays a warning page. **Don't worry:** the Konvert mobile client automatically sends a custom header `ngrok-skip-browser-warning` to bypass this warning and communicate with the API directly.

### Checking Server Logs
If document conversions are failing, inspect the logs to diagnose the issue:
* **Docker Compose**: `docker-compose logs -f`
* **Standalone Docker**: `docker logs -f konvert-backend`
