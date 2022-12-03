#!/bin/bash
COMMAND_USER=local
IDENTIFIER=c8y_Command
TRANSITION_OPERATION=0

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -d /etc/xmas ]; then
    sudo mkdir -p /etc/xmas
fi
STATE_FILE=/etc/xmas/state

LOG_FILE=/var/log/xmas.log

REMAINING=0
if [ ! -f "$STATE_FILE" ]; then
    echo "REMAINING=10" | sudo tee -a "$STATE_FILE"
fi

source "$STATE_FILE"

log() {
    local level="$1"
    shift
    echo "$(date --iso-8601=seconds 2>/dev/null || date -Iseconds) : $IDENTIFIER : ${level^^} : $*" | tee -a "$LOG_FILE"
}

debug () { log "debug" "$@"; }
info () { log "info" "$@"; }
warn () { log "warning" "$@"; }
error () { log "err" "$@"; }


cleanup() {
    error "Unexpected error"
}

trap cleanup EXIT


COMMAND=$(echo "$1" | cut -d, -f3- | xargs)
RUNNER=()

if [ "$UID" -eq 0 ]; then
    if command -v runuser >/dev/null 2>&1; then
        info "Running command as user: $COMMAND_USER"
        RUNNER+=(
            runuser --user "$COMMAND_USER" --
        )
    fi
fi

COMMAND_NAME="$COMMAND"

if [ ! -f "$COMMAND" ]; then
    COMMAND="$SCRIPT_DIR/$COMMAND"
fi

if [ ! -f "$COMMAND" ]; then
    tedge mqtt pub --qos 0 tedge/events/command_error "$(printf '{"text": "The computer says no 💥 %s was not found under %s", "type": "command_error"}' "$COMMAND_NAME" "$SCRIPT_DIR")"
    exit 1
fi

RUNNER+=(
    /bin/bash -c "$COMMAND"
)

info "Executing command: ${RUNNER[*]}"
OUTPUT=$("${RUNNER[@]}" 2>&1)
EXIT_CODE="$?"

info "$OUTPUT"

if [ $EXIT_CODE -eq 0 ]; then
    info "Command executed successfully"

    if [[ "$COMMAND_NAME" == "dispatch" ]]; then
        if [[ "$REMAINING" -le 0 ]]; then
            warn "No more items are remaining!!!"
            tedge mqtt pub --qos 0 tedge/events/vendor_dispatch_error "$(printf '{"text": "Could not dispatch as there are not items left 😭😭😭", "type": "vendor_dispatch_fail"}')"
        else
            REMAINING=$((REMAINING - 1))
            echo "REMAINING=$REMAINING" > "$STATE_FILE"

            info "Dispatched 1 item. Only $REMAINING items remaining"
            tedge mqtt pub --qos 1 'tedge/measurements' "{\"remaining\": $REMAINING}"
            
            if [[ "$REMAINING" -le 5 ]]; then
                warn "Oh no, there are not too many items left!!!"
                tedge mqtt pub --qos 0 tedge/events/vendor_dispatch_warning "$(printf '{"text": "Oh no, there are only %s items left!!!", "type": "vendor_dispatch_warning"}' "$REMAINING" )"
            else
                tedge mqtt pub --qos 0 tedge/events/vendor_dispatch "$(printf '{"text": "Dispatched 1 item. %d items remaining", "type": "vendor_dispatch"}' "$REMAINING")"
            fi
        fi
    else
        tedge mqtt pub --qos 0 tedge/events/command_info "$(printf '{"text": "%s was successful 🥳", "type": "command_info"}' "$COMMAND_NAME")"
    fi
else
    warn "Command exited with a non-zero exit code. code=$EXIT_CODE"
    tedge mqtt pub --qos 0 tedge/events/command_info "$(printf '{"text": "%s failed 💥. exit_code=%d", "type": "command_info"}' "$COMMAND_NAME" "$EXIT_CODE")"
fi

trap - EXIT

exit $EXIT_CODE
