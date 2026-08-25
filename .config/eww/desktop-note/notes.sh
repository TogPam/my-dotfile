#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# CONFIG
# =========================================================

NOTES_DIR="$HOME/.config/eww/desktop-note/data"
NOTES_FILE="$NOTES_DIR/notes.json"
EWW="eww"
EWW_WINDOW="note_board"


# =========================================================
# INIT
# =========================================================

mkdir -p "$NOTES_DIR"

if [[ ! -f "$NOTES_FILE" ]]; then
    echo "[]" > "$NOTES_FILE"
fi

if ! jq empty "$NOTES_FILE" >/dev/null 2>&1; then
    echo "[]" > "$NOTES_FILE"
fi


# =========================================================
# HELPERS
# =========================================================

load_notes() {
    jq -c '.' "$NOTES_FILE"
}


refresh_eww() {
    true
}


get_input() {
    "$EWW" get note_input_text 2>/dev/null || true
}


get_edit_id() {
    "$EWW" get note_edit_id 2>/dev/null || true
}


generate_id() {
    printf '%s-%s' "$(date +%s%N)" "$RANDOM"
}


# =========================================================
# LIST
# =========================================================

cmd_list() {
    load_notes
}


# =========================================================
# ADD
# =========================================================

cmd_add() {
    local text
    local id
    local tmp

    text="$(get_input)"

    # Không cho phép note rỗng
    if [[ -z "${text//[[:space:]]/}" ]]; then
        exit 0
    fi

    id="$(generate_id)"
    tmp="$(mktemp)"

    jq \
        --arg id "$id" \
        --arg text "$text" \
        '. + [{
            id: $id,
            text: $text,
            created_at: (now | todateiso8601),
            updated_at: (now | todateiso8601)
        }]' \
        "$NOTES_FILE" > "$tmp"

    mv "$tmp" "$NOTES_FILE"

    "$EWW" update note_input_text=""
    refresh_eww
}


# =========================================================
# UPDATE
# =========================================================

cmd_update() {
    local id
    local text
    local tmp

    id="$(get_edit_id)"
    text="$(get_input)"

    if [[ -z "$id" ]]; then
        return
    fi

    if [[ -z "${text//[[:space:]]/}" ]]; then
        return
    fi

    tmp="$(mktemp)"

    jq \
        --arg id "$id" \
        --arg text "$text" \
        'map(
            if .id == $id
            then .text = $text
                 | .updated_at = (now | todateiso8601)
            else .
            end
        )' \
        "$NOTES_FILE" > "$tmp"

    mv "$tmp" "$NOTES_FILE"

    "$EWW" update note_input_text=""
    "$EWW" update note_edit_id=""

    refresh_eww
}


# =========================================================
# SAVE
#
# Chọn ADD hoặc UPDATE dựa trên note_edit_id
# =========================================================

cmd_save() {
    local edit_id

    edit_id="$(get_edit_id)"

    if [[ -n "$edit_id" ]]; then
        cmd_update
    else
        cmd_add
    fi
}


# =========================================================
# DELETE
# =========================================================

cmd_delete() {
    local id="$1"
    local tmp

    if [[ -z "$id" ]]; then
        exit 1
    fi

    tmp="$(mktemp)"

    jq \
        --arg id "$id" \
        'map(select(.id != $id))' \
        "$NOTES_FILE" > "$tmp"

    mv "$tmp" "$NOTES_FILE"

    refresh_eww
}


# =========================================================
# CLEAR ALL
# =========================================================

cmd_clear() {
    echo "[]" > "$NOTES_FILE"

    "$EWW" update note_input_text=""
    "$EWW" update note_edit_id=""

    refresh_eww
}


# =========================================================
# MAIN
# =========================================================

case "${1:-}" in
    list)
        cmd_list
        ;;

    add)
        cmd_add
        ;;

    update)
        cmd_update
        ;;

    save)
        cmd_save
        ;;

    delete)
        if [[ $# -lt 2 ]]; then
            echo "Usage: $0 delete <note-id>" >&2
            exit 1
        fi

        cmd_delete "$2"
        ;;

    clear)
        cmd_clear
        ;;

    *)
        echo "Usage:"
        echo "  $0 list"
        echo "  $0 add"
        echo "  $0 update"
        echo "  $0 save"
        echo "  $0 delete <id>"
        echo "  $0 clear"
        exit 1
        ;;
esac
