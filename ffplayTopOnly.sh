#!/bin/bash
# Play a top-bottom video showing only the top half, scaled to fill a display,
# without altering the source aspect ratio (letterboxed/pillarboxed as
# needed). Opens a normal, draggable window sized to fill the display rather
# than true OS fullscreen (ffplay's real -fs ignores -left/-top and always
# lands on the main display), so you can still move/resize it afterward.
#
# Usage: ./ffplayTopOnly.sh [-s|--screen N] [--ipc PATH] <video-file>
#        ./ffplayTopOnly.sh --list-screens
#
#   -s, --screen N   Fill display N (see --list-screens for the index).
#                     Defaults to display 1.
#   --ipc PATH       Socket mpv listens on for IPC commands, so another process
#                     (e.g. propsync) can drive an overlay while this plays.
#                     Defaults to /tmp/mpv-topOnly.sock.
#   --list-screens   Print detected displays as "index x y width height" and
#                     exit.

set -euo pipefail

# Prints one line per connected display: "index x y width height", in the
# top-left-origin/y-down global coordinate space that SDL/ffplay's -left/-top
# expect: the primary display's top-left is (0,0), other displays are placed
# relative to it (and can have negative coordinates). Converted from Cocoa's
# bottom-left-origin/y-up NSScreen frames, flipped about the primary
# display's height.
list_screens() {
    osascript -l JavaScript -e '
        ObjC.import("Cocoa");
        var screens = $.NSScreen.screens;
        var mainH = $.NSScreen.mainScreen.frame.size.height;
        var n = screens.count;
        var lines = [];
        for (var i = 0; i < n; i++) {
            var f = screens.objectAtIndex(i).frame;
            var x = f.origin.x;
            var y = mainH - f.origin.y - f.size.height;
            lines.push([i + 1, x, y, f.size.width, f.size.height].join(" "));
        }
        lines.join("\n");
    '
}

SCREEN=1
IPC_SOCKET=/tmp/mpv-topOnly.sock

while [ $# -gt 0 ]; do
    case "$1" in
        -s|--screen)
            SCREEN="$2"
            shift 2
            ;;
        --ipc)
            IPC_SOCKET="$2"
            shift 2
            ;;
        --list-screens)
            echo "screen x y width height"
            list_screens
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -lt 1 ]; then
    echo "Usage: $0 [-s N] [--ipc PATH] <video-file>" >&2
    echo "       $0 --list-screens" >&2
    exit 1
fi

INPUT="$1"

LINE="$(list_screens | awk -v s="$SCREEN" '$1 == s')"
if [ -z "$LINE" ]; then
    echo "Screen '$SCREEN' not found. Use --list-screens to see available displays." >&2
    exit 1
fi
read -r _ X Y W H <<<"$LINE"

# A stale socket file from a previous run (e.g. one that was killed) stops mpv from binding a new
# one, so clear it first. Only the path is removed -- nothing is listening on it at this point.
rm -f "$IPC_SOCKET"

echo "mpv IPC socket: $IPC_SOCKET"
echo "Drive an overlay from another terminal with, e.g.:"
echo "  propsync 'data://{\"command\":[\"osd-overlay\",1,\"ass-events\",\"\",0,720,0,false,false]}' \\"
echo "    add <feed> --follow -p 'command/*[4]' filter '<concat(...)>' \\"
echo "    out unix://$IPC_SOCKET -f json -c '{\"isServer\":true}'"
echo "Note: mpv drops an osd-overlay when the client that set it disconnects, so that propsync"
echo "      has to keep running (--follow) for the overlay to stay up."

# Use mpv instead because it natively supports macos HW decoding.
# ffplay requires vulkan in order to decode natively, and that is often not built in the homebrew binaries.
#ffplay -hwaccel videotoolbox -vf "crop=iw:ih/2:0:0" -left "${X%.*}" -top "${Y%.*}" -x "${W%.*}" -y "${H%.*}" "$INPUT"
mpv --hwdec=videotoolbox --vf="crop=iw:ih/2:0:0" --geometry="${W%.*}x${H%.*}+${X%.*}+${Y%.*}" \
    --input-ipc-server="$IPC_SOCKET" "$INPUT"
