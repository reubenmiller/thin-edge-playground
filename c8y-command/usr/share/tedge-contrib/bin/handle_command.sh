#!/bin/bash
COMMAND_USER=local
IDENTIFIER=c8y_Command

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

log() {
    local level="$1"
    shift
    echo "$(date --iso-8601=seconds 2>/dev/null || date -Iseconds) : $IDENTIFIER : ${level^^} : $*"
}

debug () { log "debug" "$@"; }
info () { log "info" "$@"; }
warn () { log "warning" "$@"; }
error () { log "err" "$@"; }

cleanup() {
    error "Unexpected error"
}

trap cleanup EXIT

info "Machine details: $(uname -a)"

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

if [ "$COMMAND_NAME" = "help" ]; then
    info "Showing help"
    info "The following commands are available to be run"
    ls -c1 "$SCRIPT_DIR/commands"
    trap - EXIT
    exit 0
fi

if [ ! -f "$COMMAND" ]; then
    COMMAND="$SCRIPT_DIR/commands/$COMMAND"
fi

if [ ! -f "$COMMAND" ]; then
    tedge mqtt pub --qos 0 tedge/events/command_error "$(printf '{"text": "The computer says no 💥 %s was not found under %s", "type": "command_error"}' "$COMMAND_NAME" "$SCRIPT_DIR/commands")"
    trap - EXIT
    exit 1
fi

RUNNER+=(
    /bin/bash -c "$COMMAND"
)

info "Executing command: ${RUNNER[*]}"
OUTPUT=$("${RUNNER[@]}" 2>&1)
EXIT_CODE="$?"

info "$OUTPUT"
info "Command executed successfully"
tedge mqtt pub --qos 0 tedge/events/command_info "$(printf '{"text": "%s was successful 🥳", "type": "command_info"}' "$COMMAND_NAME")"

trap - EXIT

exit $EXIT_CODE
