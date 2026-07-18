# Konvert 101: Complete Setup & Self-Hosting Guide 🚀

Welcome to Konvert! Because we take user privacy seriously, we don't rely on centralized cloud servers for document processing. Instead, **you** play the role of the cloud provider. 

By following this guide, you will set up a local backend server on your computer that your mobile app will securely talk to. Your documents never leave your control, and everything is instantly deleted after processing.

Let's get everything set up in less than 10 minutes!

---

## 🛠️ Prerequisites
Before we start, verify that you have the following installed on your computer:
1. **Docker Desktop** ([Download here](https://www.docker.com/products/docker-desktop/)) - Required to run the LibreOffice backend container and Ngrok tunnel.

*(Note: Ngrok is built directly into our setup, so you don't need to download it separately!)*

---

## Step 1: Claim Your Free Static Domain (Ngrok)

We need to safely expose your local server to the internet so that your mobile app can access it from anywhere using Wi-Fi or Cellular data. We use **Ngrok** for this.

1. Sign up for a free [ngrok account](https://dashboard.ngrok.com/).
2. Find your **Auth Token** on the dashboard.
3. Claim your **Free Static Domain** (e.g., `cute-dog-123.ngrok-free.app`). This domain is yours permanently!

---

## Step 2: Setting up the Local Backend

Our backend service handles complex document conversions (like DOCX, PPTX, or XLSX formats). We have containerized it to ensure it runs fully offline and isolated on your machine.

1. **Download the Backend Files**:
   Go to the [Konvert Releases Page](https://github.com/TUSHAR91316/Konvert-Website/releases) and download the **`backend.zip`** file. Extract it, and open your Terminal / Command Prompt inside that extracted folder.

2. **Configure Your Credentials**:
   Inside the extracted folder, you will see a file named `.env.example`.
   * Rename it or copy it to just `.env`
   * Open `.env` in a text editor and paste your Ngrok Auth Token and Static Domain:
     ```env
     NGROK_AUTHTOKEN=your_auth_token_here
     NGROK_DOMAIN=cute-dog-123.ngrok-free.app
     ```

3. **Start the Server**:
   Run the following command to download all necessary tools and start your server in the background:
   ```bash
   docker-compose up -d --build
   ```
   > 🎉 **Success:** Your backend and secure Ngrok tunnel are now running in the background!

---

## Step 3: Configuring the Mobile App

Now that your personal cloud is running securely on the internet, you just need to point the Konvert app to it.

1. **Install Konvert:**
   * Download the latest APK from the **GitHub Actions / Releases** tab.

2. **Open the Settings Screen:**
   Inside the Konvert application, find and tap on "Settings" or "Configuration".

3. **Paste your Domain:**
   Look for the **Backend URL** field. 
   Paste the static URL you got from ngrok. It should look like this: `https://cute-dog-123.ngrok-free.app`.

4. **Convert Safely!**
   You're finished! Now whenever you convert a proprietary office document, your phone will securely send it to your `ngrok` tunnel, which routes it directly to the `Docker` container running on your laptop. Once done, the server immediately wipes the file data.

---

## 🙋 Frequently Asked Questions

**Does Image-to-PDF conversion require the backend?**
No! While single Image conversions (JPG, PNG to PDF) will attempt to leverage the backend first for cloud-based rendering, if the server is offline or unreachable it automatically and silently falls back to 100% offline processing using your phone's processor. Multiple image merging is always processed completely on-device.

**Do I have to do this every time?**
You only have to install Docker and set up the `.env` file once! The containers are configured to start automatically if your PC restarts. If you ever manually stop them, simply open terminal and run:
`docker-compose up -d` 

**Is it really secure?**
> [!TIP]
> Yes! ngrok provides industry-standard SSL encryption (HTTPS). Additionally, because you host the container yourself, you aren't uploading your private resumés or documents to a random third-party internet converter that might harvest your private data.
