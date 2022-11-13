## Add ssh open/close events to shell

Append the following to your `/etc/profile` profile.

```sh
if command -v tedge >/dev/null 2>&1; then
    tedge mqtt pub --qos 0 tedge/events/ssh_login_event "$(printf '{"text": "ssh session started 🛫 user=%s, ppid=%d", "type": "ssh_login"}' "$(whoami)" "$PPID")"

    on_close(){
        tedge mqtt pub --qos 0 tedge/events/ssh_logout_event "$(printf '{"text": "ssh session stopped 🏁 user=%s, ppid=%d", "type": "ssh_logoff"}' "$(whoami)" "$PPID")"
    }
    trap on_close EXIT
fi
```
