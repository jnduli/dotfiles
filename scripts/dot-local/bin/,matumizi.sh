set -euo pipefail

MEMORY_MAX=2G
# TODO: see if memory max can be configurable
# TODO: figure out how to control CPU

program=$(dmenu_path | rofi -i -dmenu)
unit_name="matumizi_${program}"
systemd-run --scope --unit="$unit_name" --user --property=MemoryMax="$MEMORY_MAX"  "$program"
