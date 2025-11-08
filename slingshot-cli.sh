#!/usr/bin/env bash
set -euo pipefail
VERSION="1.0.0"
CONFIG_DIR="$HOME/.var/app/org.vinegarhq.Sober/config/sober"
CONFIG_FILE="$CONFIG_DIR/config.json"
BACKUP_DIR="$CONFIG_DIR/backups"
ASSET_BASE="$HOME/.var/app/org.vinegarhq.Sober/data/sober/assets"
ASSET_OVERLAY="$HOME/.var/app/org.vinegarhq.Sober/data/sober/asset_overlay"
POINTER_DIR="$ASSET_OVERLAY/content/textures/Cursors/KeyboardMouse"
FONT_DIR="$ASSET_OVERLAY/content/fonts"
SHIFTLOCK_PATH="$ASSET_OVERLAY/content/textures/MouseLockedCursor.png"
MTU_CACHE="$CONFIG_DIR/optimal_mtu.cache"
MAX_BACKUPS=5
mkdir -p "$BACKUP_DIR"

main_menu() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " slingshot-cli (v$VERSION)"
    echo "──────────────────────────────────────────────"
    echo "cli tool for sober, script made by poetaste on github :3"
    echo
    echo "Choose a section:"
    echo
    echo "  1 - Asset Configuration"
    echo "  2 - Performance Tweaks"
    echo "  3 - FastFlags"
    echo "  U - Check for Updates"
    echo "  q - Quit"
    echo
    read -e -rp "Select option (1/2/3/U/q): " main_sel
    echo

    case "$main_sel" in
    1) interactive_asset ;;
    2) interactive_tweaks ;;
    3) interactive_fflags ;;
    U | u) check_for_updates ;;
    q | Q)
      clear
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid selection."
      sleep 1
      ;;
    esac
  done
}

# === UPDATE CHECKER ===
interactive_update() {
  clear
  echo "──────────────────────────────────────────────"
  echo " Update Checker"
  echo "──────────────────────────────────────────────"
  echo
  echo "Options:"
  echo "  1 - Check for updates"
  echo "  b - Back"
  echo
  read -e -rp "Select option (1/b): " choice
  echo

  case "$choice" in
  1)
    clear
    echo "Checking for updates..."
    echo

    # online version
    LATEST=$(curl -fsSL "https://raw.githubusercontent.com/YOURNAME/slingshot-cli/main/VERSION" 2>/dev/null)

    if [[ -z "$LATEST" ]]; then
      echo "Error: Unable to check for updates."
      read -rp "Press Enter to return..."
      interactive_update
      return
    fi

    echo "Current version: $VERSION"
    echo "Latest version:  $LATEST"
    echo

    if [[ "$LATEST" == "$VERSION" ]]; then
      echo "You are already on the latest version!"
      read -rp "Press Enter to return..."
      interactive_update
      return
    fi

    echo "A new update is available!"
    read -e -rp "Do you want to update? (y/n): " yn

    case "$yn" in
    y | Y)
      echo
      echo "Updating..."
      curl -fsSL "https://raw.githubusercontent.com/YOURNAME/slingshot-cli/main/slingshot-cli.sh" -o "$0"
      chmod +x "$0"
      echo "Update complete!"
      read -rp "Press Enter to return..."
      ;;
    n | N)
      echo
      echo "Update cancelled."
      read -rp "Press Enter to return..."
      ;;
    *)
      echo "Invalid choice."
      read -rp "Press Enter to return..."
      ;;
    esac
    ;;

  b | B)
    return
    ;;

  *)
    echo "Invalid selection."
    read -rp "Press Enter to return..."
    interactive_update
    ;;
  esac
}

# === ASSET HANDLING ===
interactive_asset() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " Asset Configuration"
    echo "──────────────────────────────────────────────"
    echo
    echo "Options:"
    echo "  1 - Cursor"
    echo "  2 - ShiftLock"
    echo "  3 - Font"
    echo "  4 - Server Location Hints"
    echo "  b - Back"
    echo
    read -e -rp "Select option (1/2/3/b): " choice
    echo

    case "$choice" in
    1) interactive_cursor ;;
    2) interactive_shiftlock ;;
    3) interactive_font ;;
    4) interactive_server_location ;;
    b | B) return ;;
    *)
      echo "Invalid selection."
      sleep 1
      ;;
    esac
  done
}

interactive_cursor() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " Cursor Configuration"
    echo "──────────────────────────────────────────────"
    echo
    echo "Options:"
    echo "  1 - Set Cursor Image"
    echo "  c - Clear Cursor"
    echo "  b - Back"
    echo
    read -e -rp "Select option (1/c/b): " choice
    echo

    case "$choice" in

    # === SET CURSOR ===
    1)
      clear
      echo "Select cursor type to set:"
      echo "  1 - ArrowCursor.png"
      echo "  2 - ArrowFarCursor.png"
      echo "  b - Back"
      echo
      read -e -rp "Choice (1/2/b): " type_choice

      case "$type_choice" in
      1) far=false ;;
      2) far=true ;;
      b | B) continue ;; # <— back to cursor menu
      *)
        echo "Invalid choice."
        read -rp "Press Enter to continue..."
        continue
        ;;
      esac

      echo
      read -e -rp "Enter path to cursor image (.png): " img
      img="${img/#\~/$HOME}"
      img="$(realpath -m "$img" 2>/dev/null || echo "$img")"

      if [[ ! -f "$img" ]]; then
        echo "Error: File not found: $img"
        read -rp "Press Enter to continue..."
        continue
      fi

      set_cursor "$img" "$far"

      echo
      read -rp "Press Enter to return..."
      ;;

    # === CLEAR CURSOR ===
    c | C)
      clear
      echo "Select cursor type to clear:"
      echo "  1 - ArrowCursor.png"
      echo "  2 - ArrowFarCursor.png"
      echo "  b - Back"
      echo
      read -e -rp "Choice (1/2/b): " type_choice

      case "$type_choice" in
      1) far=false ;;
      2) far=true ;;
      b | B) continue ;;
      *)
        echo "Invalid choice."
        read -rp "Press Enter to continue..."
        continue
        ;;
      esac

      clear_cursor "$far"

      echo
      read -rp "Press Enter to return..."
      ;;

    # === BACK ===
    b | B)
      return
      ;;

    # === INVALID ===
    *)
      echo "Invalid selection."
      read -rp "Press Enter to continue..."
      ;;

    esac
  done
}

interactive_shiftlock() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " ShiftLock Configuration"
    echo "──────────────────────────────────────────────"
    echo
    echo "Options:"
    echo "  1 - Set ShiftLock Image"
    echo "  c - Clear ShiftLock"
    echo "  b - Back"
    echo
    read -e -rp "Select option (1/c/b): " choice
    echo

    case "$choice" in

    # === SET SHIFTLOCK ===
    1)
      clear
      read -e -rp "Enter path to ShiftLock image (.png): " img

      img="${img/#\~/$HOME}"
      img="$(realpath -m "$img" 2>/dev/null || echo "$img")"

      if [[ ! -f "$img" ]]; then
        echo "Error: File not found: $img"
        read -rp "Press Enter to continue..."
        continue
      fi

      set_shiftlock "$img"

      echo
      read -rp "Press Enter to return..."
      ;;

    # === CLEAR SHIFTLOCK ===
    c | C)
      clear_shiftlock

      echo
      read -rp "Press Enter to return..."
      ;;

    # === BACK ===
    b | B)
      return
      ;;

    # === INVALID ===
    *)
      echo "Invalid selection."
      read -rp "Press Enter to continue..."
      ;;
    esac
  done
}

# === FONT HANDLING ===
interactive_font() {
  clear
  echo "──────────────────────────────────────────────"
  echo " Font Configuration"
  echo "──────────────────────────────────────────────"
  echo
  echo "Options:"
  echo "  1 - Set Font File"
  echo "  c - Clear Font"
  echo "  b - Back"
  echo
  read -e -rp "Select option (1/c/b): " choice
  echo

  case "$choice" in
  1)
    clear
    read -e -rp "Enter path to font file (.ttf or .otf): " font
    font="${font/#\~/$HOME}"
    font="$(realpath -m "$font" 2>/dev/null || echo "$font")"

    if [[ ! -f "$font" ]]; then
      echo "Error: File not found: $font"
      read -rp "Press Enter to return..."
      interactive_font
      return
    fi

    set_font "$font"
    ;;

  c | C)
    clear
    clear_font
    ;;

  b | B)
    return
    ;;

  *)
    echo "Invalid selection."
    read -rp "Press Enter to return..."
    interactive_font
    ;;
  esac
}

# === SERVER LOCATION HINTS ===
interactive_server_location() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " Show Server Location"
    echo "──────────────────────────────────────────────"
    echo
    #detect_server_location
    echo
    echo "When you join a server, this roughly determine where the server is located and notifies you about it."
    echo "making it easier to find a server with low ping."
    echo
    echo "run 'slingshot-cli.sh server-location' on startup to enable it :P"
    echo
    echo "  b - Back"
    echo
    read -e -rp "Choice: " c
    case "$c" in
    b | B)
      return
      ;;
    *)
      echo "Invalid option"
      sleep 1
      ;;
    esac
  done
}

# === TWEAKS HANDLING ===
interactive_tweaks() {
  while true; do
    # Gather statuses (safe, silent on failure)
    opengl_status=$(detect_opengl_status 2>/dev/null | head -n1 || echo "")
    telemetry_status=$(detect_telemetry_status 2>/dev/null | head -n1 || echo "")
    gamemode_status=$(detect_gamemode_status 2>/dev/null | head -n1 || echo "")
    graphics_status=$(detect_graphics_status 2>/dev/null | head -n1 || echo "")
    msaa_status=$(detect_msaa_status 2>/dev/null | head -n1 || echo "")
    mtu_status=$(detect_mtu_status 2>/dev/null | head -n1 || echo "")

    clear
    echo "──────────────────────────────────────────────"
    echo " Performance Tweaks"
    echo "──────────────────────────────────────────────"
    echo
    echo "Adjust system and rendering settings to improve performance."
    echo
    printf "  1. OpenGL            %s\n" "${opengl_status:-}"
    printf "  2. Telemetry         %s\n" "${telemetry_status:-}"
    printf "  3. GameMode          %s\n" "${gamemode_status:-}"
    printf "  4. Graphics Quality  %s\n" "${graphics_status:-}"
    printf "  5. MSAA              %s\n" "${msaa_status:-}"
    printf "  6. MTU               %s\n" "${mtu_status:-}"
    echo "  b. Back"
    echo
    read -e -rp "Select option (1–6/b): " choice
    echo

    case "$choice" in
    1) interactive_tweak_opengl ;;
    2) interactive_tweak_telemetry ;;
    3) interactive_tweak_gamemode ;;
    4) interactive_tweak_graphics ;;
    5) interactive_tweak_msaa ;;
    6) interactive_tweak_mtu ;;
    b | B) return ;;
    *)
      echo "Invalid selection."
      sleep 1
      ;;
    esac
  done
}

# === OPENGL ===
interactive_tweak_opengl() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " OpenGL Configuration"
    echo "──────────────────────────────────────────────"
    echo
    detect_opengl_status
    echo
    echo "  1 - Enable"
    echo "  2 - Disable"
    echo "  b - Back"
    echo
    read -e -rp "Choice: " c
    case "$c" in
    1)
      set_opengl true
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    2)
      set_opengl false
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    b | B) return ;;
    *)
      echo "Invalid option"
      sleep 1
      ;;
    esac
  done
}

# === TELEMETRY ===
interactive_tweak_telemetry() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " Telemetry Configuration"
    echo "──────────────────────────────────────────────"
    echo
    detect_telemetry_status
    echo
    echo "  1 - Enable"
    echo "  2 - Disable (recommended)"
    echo "  b - Back"
    echo
    read -e -rp "Choice: " c
    case "$c" in
    1)
      set_telemetry true
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    2)
      set_telemetry false
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    b | B) return ;;
    *)
      echo "Invalid option"
      sleep 1
      ;;
    esac
  done
}

# === GAMEMODE ===
interactive_tweak_gamemode() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " GameMode Configuration"
    echo "──────────────────────────────────────────────"
    echo
    detect_gamemode_status
    echo
    echo "  1 - Enable"
    echo "  2 - Disable"
    echo "  b - Back"
    echo
    read -e -rp "Choice: " c
    case "$c" in
    1)
      set_gamemode true
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    2)
      set_gamemode false
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    b | B) return ;;
    *)
      echo "Invalid option"
      sleep 1
      ;;
    esac
  done
}

# === GRAPHICS QUALITY ===
interactive_tweak_graphics() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo "  Graphics Quality Configuration"
    echo "──────────────────────────────────────────────"
    echo
    detect_graphics_status
    echo
    echo "Choose a graphics quality level:"
    echo "• Valid range: 1 → 21"
    echo "• Higher = better quality, lower = better FPS"
    echo
    echo "  b - Back"
    echo
    read -e -rp "Enter quality (1–21): " q

    case "$q" in
    b | B) return ;;
    '' | *[!0-9]*)
      echo
      echo "✗ Invalid input — please enter a number."
      sleep 1
      ;;
    *)
      if ((q >= 1 && q <= 21)); then
        echo
        echo "✓ Setting graphics quality to $q..."
        set_graphics "$q"
        echo
        read -rp "Press Enter to return..."
        return
      else
        echo
        echo "✗ Out of range — must be between 1 and 21."
        sleep 1
      fi
      ;;
    esac
  done
}

# === MSAA ===
interactive_tweak_msaa() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo "  MSAA Anti-Aliasing Configuration"
    echo "──────────────────────────────────────────────"
    echo
    detect_msaa_status
    echo
    echo "Choose MSAA sample level:"
    echo "• Valid: 0  2  4  8  16"
    echo "• Higher = smoother edges, more GPU usage"
    echo
    echo "  b - Back"
    echo
    read -e -rp "Enter samples (0/2/4/8/16): " ms

    case "$ms" in
    b | B) return ;;
    '' | *[!0-9]*)
      echo
      echo "✗ Invalid input — numbers only."
      sleep 1
      ;;
    0 | 2 | 4 | 8 | 16)
      if ((ms > 4)); then
        echo "WARNING: MSAA values above 4 may cause viewport rendering bugs!"
        read -rp "Continue anyway? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          echo "Operation cancelled."
          sleep 1
          continue
        fi
      fi
      echo
      echo "✓ Setting MSAA to $ms samples..."
      set_msaa "$ms"
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    *)
      echo
      echo "✗ Invalid MSAA level — must be one of: 0, 2, 4, 8, 16."
      sleep 1
      ;;
    esac
  done
}

# === MTU ===
interactive_tweak_mtu() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo "  MTU Configuration"
    echo "──────────────────────────────────────────────"
    echo
    detect_mtu_status
    echo
    echo "Choose MTU configuration method:"
    echo
    echo "  1 - Auto-detect best MTU"
    echo "  2 - Enter manually"
    echo "  r - Remove MTU override and cached value"
    echo "  b - Back"
    echo
    read -e -rp "Select option: " choice

    case "$choice" in
    1)
      echo
      echo "⟳ Running MTU auto-detection..."
      detect_mtu true
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    2)
      echo
      read -e -rp "Enter MTU value (e.g., 1400–1500): " mtu
      case "$mtu" in
      '' | *[!0-9]*)
        echo
        echo "✗ Invalid number."
        sleep 1
        ;;
      *)
        if ((mtu < 500 || mtu > 1500)); then
          echo "✗ MTU must be between 500 and 1500."
          sleep 1
        else
          echo
          echo "✓ Setting MTU to $mtu..."
          set_mtu "$mtu"
          echo
          read -rp "Press Enter to return..."
          return
        fi
        ;;
      esac
      ;;
    r | R)
      echo "Removing MTU override and cache..."
      clear_mtu
      echo
      read -rp "Press Enter to return..."
      return
      ;;
    b | B) return ;;
    *)
      echo
      echo "✗ Invalid option."
      sleep 1
      ;;
    esac
  done
}

interactive_fflags() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " FastFlags Configuration"
    echo "──────────────────────────────────────────────"
    echo
    echo "1 - Manually Set FastFlags"
    echo "2 - Presets"
    echo "3 - Undo FastFlags"
    echo "b - Back"
    echo
    read -e -rp "Select option: " choice

    case "$choice" in
    1) interactive_fflags_manual ;;
    2) interactive_fflags_presets ;;
    3)
      undo_fflags
      read -rp "Press Enter to continue..."
      ;;
    b | B) return ;;
    *)
      echo "Invalid option."
      read -rp "Press Enter..."
      ;;
    esac
  done
}

interactive_fflags_manual() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " Manual FastFlags Entry"
    echo "──────────────────────────────────────────────"
    echo
    echo "1 - Type FastFlags JSON"
    echo "2 - Load JSON from file"
    echo "3 - Clear all FastFlags"
    echo "4 - Undo FastFlags"
    echo "b - Back"
    echo
    read -e -rp "Select option: " choice

    case "$choice" in
    1)
      clear
      echo "──────────────────────────────────────────────"
      echo " Enter FastFlags JSON (press Ctrl+D when done)"
      echo "──────────────────────────────────────────────"
      echo "(Tip: You can paste multi-line JSON here)"
      echo
      echo "> Start typing below:"
      echo

      # Read JSON manually
      manual_json="$(</dev/stdin)"

      if [[ -z "$manual_json" ]]; then
        echo
        echo "No input detected. Returning to menu."
      else
        # Validate JSON before applying
        if echo "$manual_json" | jq -e . >/dev/null 2>&1; then
          echo
          echo "JSON validated successfully."
          set_fflags "$manual_json"
        else
          echo
          echo "Invalid JSON format! Please try again."
        fi
      fi

      echo
      read -rp "Press Enter to continue..."
      ;;

    2)
      read -e -rp "Enter file path: " ff
      ff="${ff/#\~/$HOME}"
      ff="$(realpath -m "$ff" 2>/dev/null || echo "$ff")"

      if [[ -f "$ff" ]]; then
        if jq -e . "$ff" >/dev/null 2>&1; then
          echo "JSON file is valid."
          set_fflags "$ff"
        else
          echo "Invalid JSON file."
        fi
      else
        echo "Error: file not found."
      fi
      read -rp "Press Enter to continue..."
      ;;

    3)
      clear_fflags
      read -rp "Press Enter to continue..."
      ;;

    4)
      undo_fflags
      read -rp "Press Enter to continue..."
      ;;

    b | B)
      return
      ;;

    *)
      echo "Invalid option."
      read -rp "Press Enter to continue..."
      ;;
    esac
  done
}

# === INTERACTIVE FFLAGS PRESETS ===
interactive_fflags_presets() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " FFlags Presets"
    echo "──────────────────────────────────────────────"
    echo
    echo "1 - Network Flags"
    echo "2 - FPS Boost"
    echo "b - Back"
    echo
    read -e -rp "Select: " fsel

    case "$fsel" in
    1) interactive_fflags_net ;;
    2) interactive_fflags_fps ;;
    b | B) return ;;
    *)
      echo "Invalid"
      read -rp "Press Enter..."
      ;;
    esac
  done
}

interactive_fflags_net() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " Network Optimization Flags"
    echo "──────────────────────────────────────────────"
    echo
    detect_netflags_status
    echo
    echo "1 - Apply"
    echo "2 - Clear"
    echo "b - Back"
    echo
    read -e -rp "Select: " nsel

    case "$nsel" in
    1)
      set_netflags
      read -rp "Press Enter..."
      ;;
    2)
      clear_netflags
      read -rp "Press Enter..."
      ;;
    b | B) return ;;
    *)
      echo "Invalid"
      read -rp "Press Enter..."
      ;;
    esac
  done
}

interactive_fflags_fps() {
  while true; do
    clear
    echo "──────────────────────────────────────────────"
    echo " FPS Boost Flags"
    echo "──────────────────────────────────────────────"
    echo
    detect_fpsboost_status
    echo
    echo "1 - Apply"
    echo "2 - Clear"
    echo "b - Back"
    echo
    read -e -rp "Select: " fpssel

    case "$fpssel" in
    1)
      set_fpsboost
      read -rp "Press Enter..."
      ;;
    2)
      clear_fpsboost
      read -rp "Press Enter..."
      ;;
    b | B) return ;;
    *)
      echo "Invalid"
      read -rp "Press Enter..."
      ;;
    esac
  done
}

# === FUNCTIONS ===
usage() {
  echo "Usage:"
  echo "  $0 asset"
  echo "  $0 tweaks"
  echo "  $0 fflags"
}

ensure_dirs() {
  mkdir -p "$POINTER_DIR"
  mkdir -p "$FONT_DIR"
  mkdir -p "$(dirname "$SHIFTLOCK_PATH")"
}
cleanup_old_backups() {
  local backup_count
  backup_count=$(ls -1 "$BACKUP_DIR"/config_*.json 2>/dev/null | wc -l)
  if [[ $backup_count -gt $MAX_BACKUPS ]]; then
    local to_delete=$((backup_count - MAX_BACKUPS))
    echo "Cleaning up old backups (keeping $MAX_BACKUPS most recent)..."
    # Delete oldest backups
    ls -1t "$BACKUP_DIR"/config_*.json | tail -n "$to_delete" | while read -r old_backup; do
      rm -f "$old_backup"
      echo "  Deleted: $(basename "$old_backup")"
    done
  fi
}
backup_config() {
  local ts
  ts=$(date +"%Y%m%d_%H%M%S")
  local backup="$BACKUP_DIR/config_$ts.json"
  cp "$CONFIG_FILE" "$backup"
  echo "Backup saved: $backup"
  # Clean up old backups after creating new one
  cleanup_old_backups
}
spinner() {
  local pid=$1
  local delay=0.1
  local spin='|/-\'
  while ps -p $pid >/dev/null 2>&1; do
    for i in $(seq 0 3); do
      printf "\r[%c] Detecting optimal MTU... " "${spin:$i:1}"
      sleep $delay
    done
  done
  printf "\r✓ MTU detection completed.           \n"
}

set_cursor() {
  local new_image="$1"
  local far_mode="${2:-false}"

  ensure_dirs

  local file_name="ArrowCursor.png"
  [[ "$far_mode" == "true" ]] && file_name="ArrowFarCursor.png"

  local pointer="$POINTER_DIR/$file_name"
  local IM_CMD
  IM_CMD=$(command -v magick || command -v convert)

  "$IM_CMD" "$new_image" -resize 32x32! "$pointer"

  echo "Cursor updated: $pointer"
}

clear_cursor() {
  local far_mode="${1:-false}"

  local file_name="ArrowCursor.png"
  [[ "$far_mode" == "true" ]] && file_name="ArrowFarCursor.png"

  local pointer="$POINTER_DIR/$file_name"

  if [[ -f "$pointer" ]]; then
    rm -f "$pointer"
    echo "Cleared overlay cursor: $pointer"
  else
    echo "No overlay cursor found to clear: $pointer"
  fi
}

# === SHIFTLOCK HANDLING ===
set_shiftlock() {
  local new_image="$1"
  ensure_dirs
  local IM_CMD
  IM_CMD=$(command -v magick || command -v convert)
  "$IM_CMD" "$new_image" -resize 32x32! "$SHIFTLOCK_PATH"
  echo "Shiftlock cursor updated: $SHIFTLOCK_PATH"
}
clear_shiftlock() {
  if [[ -f "$SHIFTLOCK_PATH" ]]; then
    rm -f "$SHIFTLOCK_PATH"
    echo "Cleared shiftlock overlay."
  else
    echo "No overlay shiftlock found to clear."
  fi
}

# === FONT HANDLING ===
set_font() {
  local new_font="$1"

  ensure_dirs
  echo "Replacing all fonts with: $new_font"

  local FONT_DIRS=("$ASSET_BASE/content/fonts" "$ASSET_BASE/fonts")

  for dir in "${FONT_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      find "$dir" -maxdepth 1 -type f \( -name "*.ttf" -o -name "*.otf" \) | while read -r src_font; do
        local base_font
        base_font=$(basename "$src_font")

        # Skip emoji fonts
        if [[ "$base_font" == "TwemojiMozilla.ttf" || "$base_font" == "RobloxEmoji.ttf" ]]; then
          echo " → Skipped emoji font: $base_font"
          continue
        fi

        cp "$new_font" "$FONT_DIR/$base_font"
        echo " → $base_font replaced"
      done
    fi
  done

  echo "All fonts replaced successfully (emoji fonts skipped)."
}

clear_font() {
  echo "Clearing all overlay fonts..."

  if [[ -d "$FONT_DIR" ]]; then
    find "$FONT_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) -delete
    echo "All overlay fonts deleted. Roblox will now use original assets."
  else
    echo "No overlay font directory found to clear."
  fi
}

# === FFLAGS HANDLING ===
set_fflags() {
  local input="$1"
  backup_config

  if [[ -f "$input" ]]; then
    input="$(<"$input")"
  fi

  if ! echo "$input" | jq -e . >/dev/null 2>&1; then
    echo "Error: invalid JSON input."
    return 1
  fi

  local temp_config="${CONFIG_FILE}.clean"

  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"

  jq 'if .fflags == null then .fflags = {} else . end' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$temp_config"

  jq --argjson new "$input" '.fflags += $new' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

  rm -f "$temp_config"

  echo "FastFlags updated successfully."
}

clear_fflags() {
  backup_config
  local temp_config="${CONFIG_FILE}.clean"

  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"

  jq '.fflags = {}' "$temp_config" >"${CONFIG_FILE}.tmp" &&
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

  rm -f "$temp_config"
  echo "All FastFlags cleared."
}

undo_fflags() {
  local latest
  latest=$(ls -t "$BACKUP_DIR"/config_*.json 2>/dev/null | head -n1 || true)

  if [[ -z "$latest" ]]; then
    echo "No backups found."
    return 1
  fi

  cp "$latest" "$CONFIG_FILE"
  echo "Restored from backup: $latest"
}

# === NETWORK OPTIMIZATION FFLAGS ===
# Credits to https://github.com/Dantezz025/Roblox-Fast-Flags?tab=readme-ov-file#lower-ping
set_netflags() {
  backup_config

  local netflags='{
    "DFIntConnectionMTUSize": 900,
    "FIntRakNetResendBufferArrayLength": "128",
    "FFlagOptimizeNetwork": "True",
    "FFlagOptimizeNetworkRouting": "True",
    "FFlagOptimizeNetworkTransport": "True",
    "FFlagOptimizeServerTickRate": "True",
    "DFIntServerPhysicsUpdateRate": "60",
    "DFIntServerTickRate": "60",
    "DFIntRakNetResendRttMultiple": "1",
    "DFIntRaknetBandwidthPingSendEveryXSeconds": "1",
    "DFIntOptimizePingThreshold": "50",
    "DFIntPlayerNetworkUpdateQueueSize": "20",
    "DFIntPlayerNetworkUpdateRate": "60",
    "DFIntNetworkPrediction": "120",
    "DFIntNetworkLatencyTolerance": "1",
    "DFIntMinimalNetworkPrediction": "0.1"
  }'

  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"

  jq 'if .fflags == null then .fflags = {} else . end' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$temp_config"

  jq --argjson new "$netflags" '.fflags += $new' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

  rm -f "$temp_config"

  echo "Network optimization flags applied (MTU default 900)."
}

clear_netflags() {
  backup_config
  local temp_config="${CONFIG_FILE}.clean"

  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"

  jq 'if .fflags then del(
    .fflags.DFIntConnectionMTUSize,
    .fflags.FIntRakNetResendBufferArrayLength,
    .fflags.FFlagOptimizeNetwork,
    .fflags.FFlagOptimizeNetworkRouting,
    .fflags.FFlagOptimizeNetworkTransport,
    .fflags.FFlagOptimizeServerTickRate,
    .fflags.DFIntServerPhysicsUpdateRate,
    .fflags.DFIntServerTickRate,
    .fflags.DFIntRakNetResendRttMultiple,
    .fflags.DFIntRaknetBandwidthPingSendEveryXSeconds,
    .fflags.DFIntOptimizePingThreshold,
    .fflags.DFIntPlayerNetworkUpdateQueueSize,
    .fflags.DFIntPlayerNetworkUpdateRate,
    .fflags.DFIntNetworkPrediction,
    .fflags.DFIntNetworkLatencyTolerance,
    .fflags.DFIntMinimalNetworkPrediction
    ) else . end' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

  rm -f "$temp_config"

  echo "Network optimization flags cleared."
}

detect_netflags_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local fflags
  fflags=$(jq -r '.fflags' "$temp_config" 2>/dev/null || echo "{}")
  rm -f "$temp_config"
  # Check for key network optimization flags
  local netflag_keys=("FFlagOptimizeNetwork" "FFlagOptimizeNetworkRouting" "DFIntServerPhysicsUpdateRate" "DFIntPlayerNetworkUpdateRate")
  local found_count=0
  for k in "${netflag_keys[@]}"; do
    if [[ $(echo "$fflags" | jq -r "has(\"$k\")") == "true" ]]; then
      found_count=$((found_count + 1))
    fi
  done
  if [[ $found_count -ge 2 ]]; then
    echo "  Network optimization flags are ACTIVE ($found_count/4 key flags detected)"
  else
    echo "  Network optimization flags are NOT active"
  fi
}

# === FPS BOOST HANDLING ===
# Credits to https://github.com/Dantezz025/Roblox-Fast-Flags?tab=readme-ov-file#boost-fps-comfort-to-play
set_fpsboost() {
  backup_config

  local fpsboost='{
    "DFIntCSGLevelOfDetailSwitchingDistance": 250,
    "DFIntCSGLevelOfDetailSwitchingDistanceL12": 500,
    "DFIntCSGLevelOfDetailSwitchingDistanceL23": 750,
    "DFIntCSGLevelOfDetailSwitchingDistanceL34": 1000,
    "DFIntTextureQualityOverride": 1,
    "FFlagDisablePostFx": true
  }'

  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"

  jq 'if .fflags == null then .fflags = {} else . end' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$temp_config"

  jq --argjson new "$fpsboost" '.fflags += $new' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

  rm -f "$temp_config"

  echo "FPS boost flags applied."
}

clear_fpsboost() {
  backup_config
  local temp_config="${CONFIG_FILE}.clean"

  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"

  jq 'if .fflags then del(
    .fflags.DFIntCSGLevelOfDetailSwitchingDistance,
    .fflags.DFIntCSGLevelOfDetailSwitchingDistanceL12,
    .fflags.DFIntCSGLevelOfDetailSwitchingDistanceL23,
    .fflags.DFIntCSGLevelOfDetailSwitchingDistanceL34,
    .fflags.DFIntTextureQualityOverride,
    .fflags.FFlagDisablePostFx
    ) else . end' "$temp_config" \
    >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

  rm -f "$temp_config"

  echo "FPS boost flags cleared."
}

detect_fpsboost_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local fflags
  fflags=$(jq -r '.fflags' "$temp_config" 2>/dev/null || echo "{}")
  rm -f "$temp_config"
  # Check for key FPS boost flags
  local fpsboost_keys=("DFIntCSGLevelOfDetailSwitchingDistance" "FFlagDisablePostFx" "DFIntTextureQualityOverride")
  local found_count=0
  for k in "${fpsboost_keys[@]}"; do
    if [[ $(echo "$fflags" | jq -r "has(\"$k\")") == "true" ]]; then
      found_count=$((found_count + 1))
    fi
  done
  if [[ $found_count -ge 2 ]]; then
    echo "  FPS boost flags are ACTIVE ($found_count/3 key flags detected)"
  else
    echo "  FPS boost flags are NOT active"
  fi
}

# === GRAPHICS QUALITY HANDLING ===
set_graphics() {
  local level="$1"
  if ! [[ "$level" =~ ^[0-9]+$ ]] || [[ "$level" -lt 1 ]] || [[ "$level" -gt 21 ]]; then
    echo "Error: Graphics quality level must be a number between 1 and 21."
    exit 1
  fi
  backup_config
  echo "Setting graphics quality level to $level (1–6 = Low, 7–21 = High)..."
  local graphics_json
  graphics_json=$(jq -n \
    --argjson lvl "$level" \
    '{
      "DFFlagDebugRenderForceTechnologyVoxel": true,
      "DFIntDebugFRMQualityLevelOverride": $lvl,
      "FIntRenderShadowIntensity": (if $lvl <= 6 then 0 else 1 end)
    }')
  set_fflags "$graphics_json"
  echo "Graphics quality updated successfully."
}
clear_graphics() {
  backup_config
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  jq 'if .fflags then del(
    .fflags.DFFlagDebugRenderForceTechnologyVoxel,
    .fflags.DFIntDebugFRMQualityLevelOverride,
    .fflags.FIntRenderShadowIntensity
    ) else . end' "$temp_config" >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  rm -f "$temp_config"
  echo "Graphics quality flags cleared."
}
detect_graphics_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local level
  level=$(jq -r '.fflags.DFIntDebugFRMQualityLevelOverride // "not set"' "$temp_config" 2>/dev/null)
  rm -f "$temp_config"
  if [[ "$level" == "not set" ]]; then
    echo "  Graphics quality not configured (using Roblox default)"
  else
    if ((level <= 6)); then
      echo "  Graphics quality: $level (Low)"
    else
      echo "  Graphics quality: $level (High)"
    fi
  fi
}

interactive_msaa() {
  echo "──────────────────────────────────────────────"
  echo " MSAA Configuration"
  echo "──────────────────────────────────────────────"
  echo
  echo "Multi-Sample Anti-Aliasing (MSAA) reduces jagged edges."
  echo
  echo "Available options:"
  echo "  0 - Disable MSAA"
  echo "  1 - 1x MSAA (minimal)"
  echo "  2 - 2x MSAA"
  echo "  4 - 4x MSAA (recommended)"
  echo "  8 - 8x MSAA (high quality, may cause viewport bugs)"
  echo "  r - Remove MSAA override and restore default"
  echo "  c - Cancel and return to main menu"
  echo
  read -rp "Enter MSAA value (0/1/2/4/8/r/c): " msaa_choice
  echo

  case "$msaa_choice" in
  0 | 1 | 2 | 4 | 8)
    if ((msaa_choice > 4)); then
      echo "WARNING: MSAA values above 4 may cause viewport rendering bugs!"
      read -rp "Continue anyway? (y/N): " confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
      fi
    fi
    set_msaa "$msaa_choice"
    ;;
  r)
    echo "Removing MSAA override..."
    clear_msaa
    ;;
  c)
    echo "Operation cancelled."
    exit 0
    ;;
  *)
    echo "Error: Invalid selection. Please choose 0, 1, 2, 4, 8, r, or c."
    exit 1
    ;;
  esac
}

set_msaa() {
  local value="$1"
  if ! [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" -ne 0 && "$value" -ne 1 && "$value" -ne 2 && "$value" -ne 4 && "$value" -ne 8 ]]; then
    echo "Error: Invalid MSAA value. Allowed: 0, 1, 2, 4, 8"
    exit 1
  fi
  backup_config
  echo "Setting Force MSAA to $value..."
  if ((value > 4)); then
    echo "CAUTION: Values over 4 may cause viewport bugs!"
  fi
  local msaa_json
  msaa_json=$(jq -n --arg val "$value" '{ "FIntDebugForceMSAASamples": $val }')
  set_fflags "$msaa_json"
  echo "MSAA override applied successfully."
}
clear_msaa() {
  backup_config
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  jq 'if .fflags then del(.fflags.FIntDebugForceMSAASamples) else . end' "$temp_config" >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  rm -f "$temp_config"
  echo "MSAA override cleared."
}
detect_msaa_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local msaa
  msaa=$(jq -r '.fflags.FIntDebugForceMSAASamples // "not set"' "$temp_config" 2>/dev/null)
  rm -f "$temp_config"
  if [[ "$msaa" != "not set" ]]; then
    echo "  MSAA is set to: ${msaa}x"
    if ((msaa > 4)); then
      echo "(values >4 may cause viewport bugs)"
    fi
  else
    echo "  MSAA override not configured (using default)"
  fi
}
# === OPENGL HANDLING ===
set_opengl() {
  local value="${1:-true}"
  [[ "$value" == "true" || "$value" == "false" ]] || {
    echo "Usage: $0 set opengl [true|false]"
    exit 1
  }
  backup_config
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  jq --argjson val "$value" '.use_opengl = $val' "$temp_config" >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  rm -f "$temp_config"
  echo "Set use_opengl to $value"
}
detect_opengl_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local state
  state=$(jq -r '.use_opengl' "$temp_config" 2>/dev/null || echo "null")
  rm -f "$temp_config"
  case "$state" in
  true) echo "  OpenGL is currently ENABLED." ;;
  false) echo "  Vulkan is currently in use (OpenGL disabled)." ;;
  *) echo "  OpenGL setting not found in config.json." ;;
  esac
}
# === TELEMETRY HANDLING ===
set_telemetry() {
  local value="${1:-true}"
  backup_config
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  if [[ "$value" == "false" ]]; then
    jq '.fflags += {
      "FFlagDebugDisableTelemetryEphemeralCounter": true,
      "FFlagDebugDisableTelemetryEphemeralStat": true,
      "FFlagDebugDisableTelemetryEventIngest": true,
      "FFlagDebugDisableTelemetryPoint": true,
      "FFlagDebugDisableTelemetryV2Counter": true,
      "FFlagDebugDisableTelemetryV2Event": true,
      "FFlagDebugDisableTelemetryV2Stat": true
    }' "$temp_config" >"${CONFIG_FILE}.tmp"
    echo "Telemetry has been disabled."
  else
    jq 'if .fflags then
  del(.fflags.FFlagDebugDisableTelemetryEphemeralCounter,
  .fflags.FFlagDebugDisableTelemetryEphemeralStat,
  .fflags.FFlagDebugDisableTelemetryEventIngest,
  .fflags.FFlagDebugDisableTelemetryPoint,
  .fflags.FFlagDebugDisableTelemetryV2Counter,
  .fflags.FFlagDebugDisableTelemetryV2Event,
  .fflags.FFlagDebugDisableTelemetryV2Stat)
else . end' "$temp_config" >"${CONFIG_FILE}.tmp"
    echo "Telemetry has been enabled."
  fi
  mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  rm -f "$temp_config"
}
detect_telemetry_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local fflags
  fflags=$(jq -r '.fflags' "$temp_config" 2>/dev/null || echo "{}")
  rm -f "$temp_config"
  local disabled_keys=("FFlagDebugDisableTelemetryEphemeralCounter" "FFlagDebugDisableTelemetryEphemeralStat" "FFlagDebugDisableTelemetryEventIngest" "FFlagDebugDisableTelemetryPoint" "FFlagDebugDisableTelemetryV2Counter" "FFlagDebugDisableTelemetryV2Event" "FFlagDebugDisableTelemetryV2Stat")
  for k in "${disabled_keys[@]}"; do
    if [[ $(echo "$fflags" | jq -r "has(\"$k\")") == "true" ]]; then
      echo "  Telemetry is currently DISABLED."
      return
    fi
  done
  echo "  Telemetry is currently ENABLED."
}
# === GAMEMODE HANDLING ===
set_gamemode() {
  local value="${1:-true}"
  [[ "$value" == "true" || "$value" == "false" ]] || {
    echo "Usage: $0 set gamemode [true|false]"
    exit 1
  }
  backup_config
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  jq --argjson val "$value" '.enable_gamemode = $val' "$temp_config" >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  rm -f "$temp_config"
  echo "Set enable_gamemode to $value"
}
detect_gamemode_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local state
  state=$(jq -r '.enable_gamemode' "$temp_config" 2>/dev/null || echo "null")
  rm -f "$temp_config"
  case "$state" in
  true) echo "  GameMode is currently ENABLED." ;;
  false) echo "  GameMode is currently DISABLED." ;;
  *) echo "  enable_gamemode not found in config.json." ;;
  esac
}
# === MTU HANDLING ===
test_mtu_latency() {
  local mtu=$1
  local host="roblox.com"
  local attempts=7
  local packet=$((mtu - 28))
  local sum=0
  local success=0
  for i in $(seq 1 "$attempts"); do
    # Capture both stdout and stderr
    local output
    output=$(ping -c1 -M do -s "$packet" -W 2 "$host" 2>&1)
    # Detect fatal MTU errors
    if grep -qE "Message too long|frag needed|Packet needs to be fragmented" <<<"$output"; then
      echo "fail"
      return
    fi
    # Extract latency from "time=XX ms"
    local t
    t=$(awk -F'=' '/time=/{print $4}' <<<"$output")
    if [[ -n "$t" ]]; then
      sum=$(awk -v s="$sum" -v v="$t" 'BEGIN{printf "%.4f", s+v}')
      success=$((success + 1))
    fi
    sleep 0.2
  done
  if ((success > 0)); then
    awk -v s="$sum" -v c="$success" 'BEGIN{printf "%.2f", s/c}'
  else
    echo "9999"
  fi
}
# Detect the optimal MTU based on average latency
detect_mtu() {
  local force="${1:-false}"
  if [[ "$force" != "true" && -f "$MTU_CACHE" ]]; then
    local cached
    cached=$(<"$MTU_CACHE")
    echo "Using cached optimal MTU: $cached"
    set_mtu "$cached"
    return
  fi
  echo "=== MTU Auto-Detection Started ==="
  echo "Testing MTUs from 1500 down to 900 for best average latency..."
  local best_mtu=0
  local best_latency=9999
  local mtus=($(seq 1500 -10 900))
  local total=${#mtus[@]}
  local count=0
  local spin='|/-\'
  for mtu in "${mtus[@]}"; do
    count=$((count + 1))
    local packet=$((mtu - 28))
    # spinner frame
    local i=$((count % 4))
    printf "\r[%c] Testing MTU %d (%d/%d)..." "${spin:$i:1}" "$mtu" "$count" "$total"
    local latency
    latency=$(test_mtu_latency "$mtu")
    # clear spinner line
    printf "\r\033[K"
    if (($(awk -v l="$latency" 'BEGIN{print (l>=9999)?1:0}'))); then
      echo "MTU $mtu → failed all tests."
      continue
    fi
    local update
    update=$(awk -v l="$latency" -v b="$best_latency" -v m="$mtu" -v bm="$best_mtu" \
      'BEGIN { if(l < b-1) print 1; else if(l <= b+1 && m > bm) print 1; else print 0 }')
    if [[ "$update" == "1" ]]; then
      best_latency="$latency"
      best_mtu="$mtu"
    fi
    echo "MTU $mtu → Avg latency: ${latency}ms"
  done
  if ((best_mtu == 0)); then
    best_mtu=1472
    best_latency="N/A"
  fi
  # Verify best MTU and fallback if needed
  if [[ "$(test_mtu_latency "$best_mtu")" == "fail" ]]; then
    echo "MTU $best_mtu failed verification, lowering..."
    for ((m = best_mtu - 10; m >= 900; m -= 10)); do
      if [[ "$(test_mtu_latency "$m")" != "fail" ]]; then
        echo "Using fallback MTU: $m"
        best_mtu="$m"
        break
      fi
    done
  fi
  echo
  echo "=== MTU Detection Complete ==="
  echo "Optimal MTU: $best_mtu"
  echo "Best average latency: ${best_latency}ms"
  echo "$best_mtu" >"$MTU_CACHE"
  set_mtu "$best_mtu"
}

interactive_mtu() {
  echo "──────────────────────────────────────────────"
  echo " MTU Configuration"
  echo "──────────────────────────────────────────────"
  echo
  echo "MTU (Maximum Transmission Unit) affects network performance."
  echo "Lower values may reduce latency but can decrease throughput."
  echo
  echo "Options:"
  echo "  1 - Auto-detect optimal MTU (recommended)"
  echo "  2 - Enter custom MTU value (500–1500)"
  echo "  r - Remove MTU override and cached value"
  echo "  c - Cancel and return to main menu"
  echo
  read -rp "Select option (1/2/r/c): " mtu_choice
  echo

  case "$mtu_choice" in
  1)
    echo "Running MTU auto-detection..."
    detect_mtu true
    ;;
  2)
    read -rp "Enter MTU value (500–1500): " custom_mtu
    if ! [[ "$custom_mtu" =~ ^[0-9]+$ ]] || ((custom_mtu < 500 || custom_mtu > 1500)); then
      echo "Error: MTU must be a number between 500 and 1500."
      exit 1
    fi
    set_mtu "$custom_mtu"
    ;;
  r)
    echo "Removing MTU override and cache..."
    clear_mtu
    ;;
  c)
    echo "Operation cancelled."
    exit 0
    ;;
  *)
    echo "Error: Invalid selection. Please choose 1, 2, r, or c."
    exit 1
    ;;
  esac
}

# Set MTU manually in config.json
set_mtu() {
  local mtu_value="$1"
  if ! [[ "$mtu_value" =~ ^[0-9]+$ ]] || [[ "$mtu_value" -lt 500 ]] || [[ "$mtu_value" -gt 1500 ]]; then
    echo "Error: MTU must be a number between 500 and 1500"
    exit 1
  fi
  backup_config
  local mtu_json="{\"DFIntConnectionMTUSize\": \"$mtu_value\"}"
  set_fflags "$mtu_json"
  echo "MTU set to: $mtu_value"
}
# Clear MTU flag and cache
clear_mtu() {
  backup_config
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  jq 'if .fflags then del(.fflags.DFIntConnectionMTUSize) else . end' "$temp_config" >"${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  rm -f "$temp_config"
  [[ -f "$MTU_CACHE" ]] && rm -f "$MTU_CACHE"
  echo "MTU flag cleared."
}
# Detect MTU status
detect_mtu_status() {
  local temp_config="${CONFIG_FILE}.clean"
  grep -v '^[[:space:]]*//\|^//' "$CONFIG_FILE" >"$temp_config"
  local mtu_value
  mtu_value=$(jq -r '.fflags.DFIntConnectionMTUSize // "not set"' "$temp_config" 2>/dev/null)
  rm -f "$temp_config"
  if [[ "$mtu_value" != "not set" ]]; then
    echo "  MTU is set to: $mtu_value"
    if [[ -f "$MTU_CACHE" && $(cat "$MTU_CACHE") == "$mtu_value" ]]; then
      echo "    (auto-detected value)"
    fi
  else
    echo "  MTU is not configured (using Roblox default)"
  fi
}

run_server_region_watcher() {
  set -u

  LOG="$HOME/.var/app/org.vinegarhq.Sober/data/sober/sober_logs/latest.log"

  # --- XDG Cache Directory -----------------------------------------------------
  CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/slingshot"
  mkdir -p "$CACHE_DIR"

  ICON_PATH="$CACHE_DIR/slingshot_icon.png"
  ICON_RAW="$CACHE_DIR/slingshot_icon_raw.png"

  echo "Roblox Server Region Watcher (CLI)"
  echo "Watching log: $LOG"
  echo "Cache: $CACHE_DIR"
  echo

  # --- One-time icon setup -----------------------------------------------------
  if [[ ! -f "$ICON_PATH" ]]; then
    ICON_URL="https://static.wikia.nocookie.net/roblox/images/6/68/SlingshotModel.png/revision/latest?cb=20210323022840"

    echo "Setting up notification icon in cache..."
    if curl -s -L "$ICON_URL" -o "$ICON_RAW"; then
      if command -v convert &>/dev/null; then
        convert "$ICON_RAW" -resize 64x64 "$ICON_PATH" 2>/dev/null || cp "$ICON_RAW" "$ICON_PATH"
      else
        cp "$ICON_RAW" "$ICON_PATH"
      fi
      echo "Icon saved: $ICON_PATH"
    else
      echo "Failed to fetch icon — continuing without it"
      ICON_PATH=""
    fi
    echo
  fi

  # --- Notifications -----------------------------------------------------------
  if command -v notify-send &>/dev/null; then
    NOTIFY=true
    echo "Notifications enabled"
  else
    NOTIFY=false
    echo "notify-send not found — notifications disabled"
  fi
  echo

  notify() {
    if $NOTIFY; then
      if [[ -n "$ICON_PATH" && -f "$ICON_PATH" ]]; then
        notify-send -u "${3:-normal}" -i "$ICON_PATH" "$1" "$2"
      else
        notify-send -u "${3:-normal}" "$1" "$2"
      fi
    fi
  }

  # --- Region lookup -----------------------------------------------------------
  lookup_region() {
    local ip="$1"
    [[ -z "$ip" ]] && {
      echo "Unknown"
      return
    }

    local resp
    resp=$(curl -s --connect-timeout 3 -m 6 "https://ipinfo.io/$ip/json" || true)
    [[ -z "$resp" ]] && {
      echo "Unknown"
      return
    }

    local city region country out
    city=$(echo "$resp" | jq -r '.city // empty')
    region=$(echo "$resp" | jq -r '.region // empty')
    country=$(echo "$resp" | jq -r '.country // empty')

    [[ -n "$city" ]] && out="$city"
    [[ -n "$region" ]] && out="${out:+$out, }$region"
    [[ -n "$country" ]] && out="${out:+$out, }$country"

    echo "${out:-Unknown}"
  }

  extract_ip() {
    grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' <<<"$1" | head -n1 || true
  }

  # --- State -------------------------------------------------------------------
  last_rcc_ip=""
  last_rcc_ts=0
  rcc_timeout=10

  last_notif_ts=0
  notif_cooldown=3

  # --- Daemon log watcher ------------------------------------------------------
  tail -n0 -F "$LOG" 2>/dev/null | while read -r line || [[ -n "$line" ]]; do

    if grep -qE "RCC Server( Address)?" <<<"$line"; then
      ip=$(extract_ip "$line")
      [[ -n "$ip" ]] && last_rcc_ip="$ip" && last_rcc_ts=$(date +%s)
    fi

    if grep -q "UDMUX" <<<"$line"; then
      udmux_ip=$(extract_ip "$line")

      if [[ -z "$udmux_ip" ]]; then
        now=$(date +%s)
        ((now - last_rcc_ts <= rcc_timeout)) && udmux_ip="$last_rcc_ip"
      fi

      rcc_inline=$(grep -oE 'RCC Server[^,]*([0-9]{1,3}\.){3}[0-9]{1,3}' <<<"$line" || true)
      rcc_ip=$(extract_ip "$rcc_inline")
      rcc_ip="${rcc_ip:-$last_rcc_ip}"

      region="Unknown"
      [[ -n "$udmux_ip" ]] && region=$(lookup_region "$udmux_ip")
      [[ "$region" == "Unknown" && -n "$rcc_ip" ]] && region=$(lookup_region "$rcc_ip")

      echo "Connected — Region: $region"

      now=$(date +%s)
      if ((now - last_notif_ts >= notif_cooldown)); then
        notify "Server Connected" "Region: $region"
        last_notif_ts=$now
      fi
    fi

  done
}

check_dependencies() {
  local missing=()
  local deps=(jq curl notify-send convert)

  echo "Checking dependencies..."

  for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  if ((${#missing[@]} > 0)); then
    echo
    echo "Missing dependencies detected!"
    echo "The following required tools are not installed:"
    for m in "${missing[@]}"; do
      echo "  - $m"
    done
    echo
    echo "Please install them before running this script again."
    echo "Exiting..."
    exit 1
  fi

  echo "All dependencies found."
  echo
}

check_dependencies

if [[ $# -lt 1 ]]; then
  main_menu
  exit 0
fi

require_args() {
  [[ $# -eq "$1" ]] || {
    usage
    exit 1
  }
}
require_min_args() {
  [[ $# -ge "$1" ]] || {
    usage
    exit 1
  }
}
case "$1" in
server-location)
  run_server_region_watcher
  ;;
fflags)
  interactive_fflags
  ;;
tweaks)
  interactive_tweaks
  ;;
asset)
  interactive_asset
  ;;

set)
  require_min_args 2
  shift
  subcmd="$1"
  shift

  case "$subcmd" in
  cursor)
    if [[ $# -eq 0 ]]; then
      interactive_cursor
    else
      far=false
      [[ "${2:-}" == "--far" ]] && far=true
      set_cursor "$1" "$far"
    fi
    ;;
  shiftlock)
    require_args 1
    set_shiftlock "$1"
    ;;
  font)
    require_args 1
    set_font "$1"
    ;;
  fflags)
    require_args 1
    set_fflags "$1"
    ;;
  opengl) set_opengl "${1:-true}" ;;
  telemetry)
    require_args 1
    set_telemetry "$1"
    ;;
  gamemode)
    require_args 1
    set_gamemode "$1"
    ;;
  graphics)
    require_args 1
    set_graphics "$1"
    ;;
  msaa)
    if [[ $# -eq 1 ]]; then set_msaa "$1"; else interactive_msaa; fi
    ;;
  mtu)
    if [[ $# -eq 1 ]]; then set_mtu "$1"; else interactive_mtu; fi
    ;;
  tweak)
    require_min_args 1
    case "$1" in
    netflags) set_netflags ;;
    fpsboost) set_fpsboost ;;
    *)
      echo "Unknown tweak: $1"
      echo "Available tweaks: netflags, fpsboost"
      exit 1
      ;;
    esac
    ;;
  *) usage ;;
  esac
  ;;
clear)
  require_min_args 2
  shift
  subcmd="$1"
  shift

  case "$subcmd" in
  cursor)
    far=false
    [[ "${1:-}" == "--far" ]] && far=true
    clear_cursor "$far"
    ;;
  shiftlock) clear_shiftlock ;;
  font) clear_font ;;
  fflags) clear_fflags ;;
  graphics) clear_graphics ;;
  msaa) clear_msaa ;;
  mtu) clear_mtu ;;
  tweak)
    require_min_args 1
    case "$1" in
    netflags) clear_netflags ;;
    fpsboost) clear_fpsboost ;;
    *)
      echo "Unknown tweak: $1"
      echo "Available tweaks: netflags, fpsboost"
      exit 1
      ;;
    esac
    ;;
  *) usage ;;
  esac
  ;;
detect)
  require_min_args 2
  shift
  subcmd="$1"
  shift

  case "$subcmd" in
  opengl) detect_opengl_status ;;
  telemetry) detect_telemetry_status ;;
  gamemode) detect_gamemode_status ;;
  netflags) detect_netflags_status ;;
  mtu)
    force=false
    [[ "${1:-}" == "--force" ]] && force=true
    detect_mtu "$force"
    ;;
  *) usage ;;
  esac
  ;;
undo)
  require_args 2
  shift
  [[ "$1" == "fflags" ]] && undo_fflags || usage
  ;;

*)
  usage
  ;;
esac
