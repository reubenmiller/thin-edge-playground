#!/bin/bash

set -e

DISK_USAGE_PERCENT=$(df / | tail -1 | sed 's/ \+/ /g' | cut -d' ' -f5 | tr -d "%")
DISK_USAGE_THRESHOLD=

if [ -f /etc/tedge-utils/config ]; then
    source /etc/tedge-utils/config 2>/dev/null || true
fi

FLAG=/etc/tedge-utils/.disk_usage_high

if [ "$DISK_USAGE_PERCENT" -ge "${DISK_USAGE_THRESHOLD:-5}" ]; then
    tedge mqtt pub --retain --qos 0 tedge/alarms/major/disk_usage_high "$(printf '{"text": "Disk usage is high 🚨 current=%d%%, threshold=%d%%"}' "$DISK_USAGE_PERCENT" "${DISK_USAGE_THRESHOLD:-5}")"
    touch "$FLAG"
else
    if [ -f "$FLAG" ]; then
        echo "Clearing alarm"
        tedge mqtt pub --retain --qos 0 tedge/alarms/major/disk_usage_high ""
        rm -f "$FLAG"
    fi
fi
