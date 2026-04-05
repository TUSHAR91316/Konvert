# Konvert 101: Complete Setup & Self-Hosting Guide 🚀

Welcome to Konvert! Because we take user privacy seriously, we don't rely on centralized cloud servers for document processing. Instead, **you** play the role of the cloud provider. 

By following this guide, you will set up a local backend server on your computer that your mobile app will securely talk to. Your documents never leave your control, and everything is instantly deleted after processing.

Let's get everything set up in less than 10 minutes!

---

## 🛠️ Prerequisites
Before we start, verify that you have the following installed on your computer:
1. **Docker Desktop** ([Download here](https://www.docker.com/products/docker-desktop/)) - Required to run the LibreOffice backend container.
2. **ngrok** ([Download here](https://ngrok.com/download)) - Required to securely connect your phone to your computer.

---

## Step 1: Setting up the Local Backend

Our backend service handles complex document conversions (like DOCX, PPTX, or XLSX formats). We have containerized it to ensure it runs fully offline and isolated on your machine.

1. **Download the Backend Files**:
   Because the Konvert mobile app is closed-source, you cannot track or `git clone` the source code. Instead, go to the [Konvert Releases Page](https://github.com/TUSHAR91316/Konvert-Website/releases) and download the **`backend.zip`** file. Extract it, and open your Terminal / Command Prompt inside that extracted folder.

2. **Build the Backend Container**:
   This command downloads all necessary tools (Python + FastAPI + LibreOffice) to process your files securely.
   ```bash
   docker build -t converter-backend .
   ```

3. **Run your Server**:
   Start the backend so it listens for requests on port 8080.
   ```bash
   docker run -d -p 8080:8080 converter-backend
   ```
   > 🎉 **Success:** Your backend is now running locally! But right now, your phone can't see it. Let's fix that.

---

## Step 2: Going Global with ngrok

We need to safely expose your local port `8080` to the internet so that your mobile app can access it from anywhere using Wi-Fi or Cellular data. We use **ngrok** for this.

1. Sign up for a free [ngrok account](https://dashboard.ngrok.com/).
2. Authenticate your terminal using the token provided on the dashboard:
   ```bash
   ngrok config add-authtoken <your-auth-token>
   ```
3. Locate your **Free Static Domain** in the ngrok dashboard (e.g., `cute-dog-123.ngrok-free.app`). This domain is yours permanently!
4. **Start the tunnel:**
   ```bash
   ngrok http --domain=cute-dog-123.ngrok-free.app 8080
   ```
   *Tip (Run & Forget): If you use a personal Windows device, you can run ngrok silently by creating a `.bat` script:*
   ```bat
   @ECHO OFF
   Start-Process ngrok -ArgumentList "http --domain=cute-dog-123.ngrok-free.app 8080" -WindowStyle Hidden
   ```
   By using this `.bat` file, ngrok runs completely in the background—you can run it and forget it! 
   
   *(Note: If you didn't use the `.bat` file and manually ran the `ngrok http` command in your terminal, you must leave that terminal window open).*

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
No! Image conversions (JPG, PNG to PDF) are 100% processed completely offline using your phone's processor. You only need to run the Docker backend when processing heavy documents like Word or Excel files.

**Do I have to do this every time?**
You only have to install Docker and claim the ngrok domain once! For daily usage, simply open terminal and run:
`docker run -d -p 8080:8080 converter-backend` and your `ngrok http ...` command whenever you need it.

**Is it really secure?**
> [!TIP]
> Yes! ngrok provides industry-standard SSL encryption (HTTPS). Additionally, because you host the container yourself, you aren't uploading your private resumés or documents to a random third-party internet converter that might harvest your private data.
