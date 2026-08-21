#!/bin/bash

# Đường dẫn lưu file dữ liệu ghi chú
NOTES_FILE="$HOME/.cache/eww_notes.json"

# Khởi tạo file JSON rỗng nếu chưa tồn tại
if [ ! -f "$NOTES_FILE" ]; then
    echo "[]" > "$NOTES_FILE"
fi

# Hàm cập nhật biến Eww ngay lập tức để giao diện tự render lại
update_eww() {
    eww update notes_json="$(cat "$NOTES_FILE")"
}

case "$1" in
    "init")
        update_eww
        ;;
    "add")
        TEXT="$2"
        if [ -n "$TEXT" ]; then
            ID=$(date +%s%N) # Tạo ID duy nhất bằng mili-giây
            jq --arg id "$ID" --arg text "$TEXT" '. + [{"id": $id, "text": $text}]' "$NOTES_FILE" > "${NOTES_FILE}.tmp" && mv "${NOTES_FILE}.tmp" "$NOTES_FILE"
            update_eww
        fi
        ;;
    "delete")
        ID="$2"
        jq --arg id "$ID" 'map(select(.id != $id))' "$NOTES_FILE" > "${NOTES_FILE}.tmp" && mv "${NOTES_FILE}.tmp" "$NOTES_FILE"
        update_eww
        ;;
esac
