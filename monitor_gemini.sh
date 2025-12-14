#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Load Configuration from .env
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Error: Configuration file not found at $ENV_FILE"
    echo "Please copy .env.example to .env and configure it."
    exit 1
fi

# Set Defaults
GEMINI_CMD="${GEMINI_CMD:-gemini}"
LOG_FILE="${LOG_FILE:-$SCRIPT_DIR/monitor.log}"

echo "------------------------------------------------" >> "$LOG_FILE"
echo "正在啟動全域監控系統... $(date)" >> "$LOG_FILE"
echo "監控目標: ${WATCH_DIRS[*]}" >> "$LOG_FILE"

if ! command -v fswatch &> /dev/null; then
    echo "錯誤: 找不到 fswatch 指令" >> "$LOG_FILE"
    exit 1
fi

fswatch -0 -r --event Created --event MovedTo "${WATCH_DIRS[@]}" | while read -d "" event_path; do
    
    filename=$(basename "$event_path")
    dir_path=$(dirname "$event_path")

    if [[ ! "$filename" =~ \.(png|jpg|jpeg|webp|PNG|JPG|JPEG|WEBP)$ ]]; then
        continue
    fi

    if [[ "$filename" == *"_compressed"* ]]; then
        continue
    fi

    if [[ "$filename" =~ \ [0-9]+ ]]; then
        continue
    fi

    echo "------------------------------------------------" >> "$LOG_FILE"
    echo "發現圖片: $event_path" >> "$LOG_FILE"

    sleep 1

    cd "$dir_path" || { echo "無法進入目錄: $dir_path" >> "$LOG_FILE"; continue; }

    echo "請求 Gemini 命名中..." >> "$LOG_FILE"

    new_name=$($GEMINI_CMD -p "You are a file renaming assistant. 
    Task: Rename the image based on its visual content.
    Input File: $event_path
    
    Rules:
    1. Output ONLY the new filename. No markdown, no quotes.
    2. Format: snake_case (e.g., meeting_notes_2024.png).
    3. Keep the original file extension.
    4. Be concise and descriptive.")

    new_name=$(echo "$new_name" | xargs)

    if [ -n "$new_name" ]; then
        new_full_path="$dir_path/$new_name"
        
        if [ "$filename" == "$new_name" ]; then
            echo "檔名不變。" >> "$LOG_FILE"
            continue
        fi

        if [ -e "$new_full_path" ]; then
            echo "⚠️ 目標檔案已存在: $new_name" >> "$LOG_FILE"
        else
            mv "$event_path" "$new_full_path"
            echo "✅ 成功更名為: $new_name" >> "$LOG_FILE"
        fi
    else
        echo "❌ Gemini 未回傳有效檔名" >> "$LOG_FILE"
    fi
done
