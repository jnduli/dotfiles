set -euo pipefail

MEMORY_OPTIONS=("MemoryHigh=4G" "MemoryHigh=8G" "MemoryHigh=12G")

MEMORY_HIGH="MemoryHigh=4G"
# default is 100
CPU_WEIGHT="CPUWeight=40"

memory_chosen=$(printf "%s\n" "${MEMORY_OPTIONS[@]}" |  rofi -font 'iosevka 20' -i -dmenu  -matching fuzzy -p "Choose mem:")

program=$(dmenu_path | rofi -font 'iosevka 20' -i -dmenu  -matching fuzzy -p "$memory_chosen;$CPU_WEIGHT:")
unit_name="matumizi_${program}"
status=$(systemctl  --user is-active $unit_name || true)

echo "Found status for $unit_name as $status: NOW"

if [[ $status == "active" || $status == "reloading" || $status == "activating" ]]; then
    echo "Unit $unit_name has the $status: $status; Not doing anything"
else
    if [[ $status == "failed" || $status == "inactive" ]]; then
        echo "Stopping unit $unit_name"
        systemctl --user stop $unit_name.scope || true
        systemctl --user reset-failed $unit_name.scope || true
    fi
    echo "Starting unit $unit_name"
    systemd-run --scope --unit="$unit_name" --user --property="$memory_chosen" --property="$CPU_WEIGHT"  "$program"
fi
