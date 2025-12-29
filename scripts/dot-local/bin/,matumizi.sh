set -euo pipefail

MEMORY_OPTIONS=("MemoryHigh=4G" "MemoryHigh=8G" "MemoryHigh=12G")

MEMORY_HIGH="MemoryHigh=4G"
# default is 100
CPU_WEIGHT="CPUWeight=40"

memory_chosen=$(printf "%s\n" "${MEMORY_OPTIONS[@]}" |  rofi -font 'iosevka 20' -i -dmenu  -matching fuzzy -p "Choose mem:")

program=$(dmenu_path | rofi -font 'iosevka 20' -i -dmenu  -matching fuzzy -p "$memory_chosen;$CPU_WEIGHT:")
unit_name="matumizi_${program}"
systemd-run --scope --unit="$unit_name" --user --property="$memory_chosen" --property="$CPU_WEIGHT"  "$program"
