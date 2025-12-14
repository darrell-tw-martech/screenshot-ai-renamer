# AI Auto-Rename Screenshot 📸

A smart background utility for macOS that automatically renames your screenshots based on their visual content using Google Gemini AI.

Stop dealing with files like `Screenshot 2024-12-14 at 10.00.00.png`. Let AI rename them to `login_page_error.png` or `cat_playing_ball.png` instantly.

## ✨ Features

- **Real-time Monitoring**: Watches specific folders for new images.
- **AI-Powered**: Uses Gemini CLI to analyze and rename files.
- **Smart Filtering**: Ignores temporary files, duplicates (` 1`, ` 2`), and non-image files.
- **Recursive Watch**: Can monitor subdirectories (great for Blogs or Project folders).
- **Background Service**: Runs silently in the background using macOS Launch Agents.

## 🛠 Prerequisites

Before using this tool, you need to install the following dependencies:

1.  **fswatch**: A file change monitor.
    ```bash
    brew install fswatch
    ```

2.  **Gemini CLI**: The interface to the AI model.
    *(Assuming you have a tool named 'gemini' installed. If this is a custom tool, ensure it's in your PATH)*

## 🚀 Installation & Setup

### 1. Clone the repository
```bash
git clone https://github.com/darrell-tw-martech/screenshot-ai-renamer.git
cd screenshot-ai-renamer
```

### 2. Setup (Two Options)

#### Option A: Quick Setup (Recommended) 🤖
Run the interactive setup script. It will auto-detect your screenshot folder and Gemini installation.
```bash
./setup.sh
```
Follow the on-screen prompts to add extra folders (like your Blog).

#### Option B: Manual Configuration
If you prefer to set it up manually:
```bash
cp .env.example .env
nano .env
```
**Variables to set in `.env`:**

| Variable | Description | Example |
| :--- | :--- | :--- |
| `WATCH_DIRS` | **(Required)** A list of folders to watch. Space-separated, inside parentheses. | `("/Users/me/Desktop" "/Users/me/Blog/images")` |
| `GEMINI_CMD` | Path to your gemini executable. | `/opt/homebrew/bin/gemini` |
| `LOG_FILE` | Where to save logs. | `/path/to/monitor.log` |

### 3. Start Manually (Testing)
You can run the script directly to test if it works:
```bash
./monitor_gemini.sh
```
Try taking a screenshot. If you see logs and the file is renamed, it works!

## 🤖 Run in Background (Auto-Start)

To have this script run automatically when you log in, you need to set up a `launchd` service.

1. **Edit the `.plist` file (Advanced)**
   You will need to create a `.plist` file pointing to the **absolute path** of `monitor_gemini.sh` on your machine.
   
   *(Note: Since `.plist` files require absolute paths, you cannot simply copy a generic one. You must edit the `<string>/path/to/monitor_gemini.sh</string>` part in the plist file.)*

2. **Load the service**
   ```bash
   cp com.darrellwang.geminimonitor.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.darrellwang.geminimonitor.plist
   ```

## 📝 License
MIT