#!/usr/bin/python3
import json
import logging
import subprocess
from paho.mqtt import client as mqtt_client


LOGGER = logging.getLogger()
broker = 'localhost'
port = 1883
client_id = 'software-monitor-client'


def get_version():
    output = subprocess.check_output(["dpkg", "--status", "c8y-xmas-plugin"], text=True)
    version = ""

    for line in output.splitlines():
        if line.startswith("Version: "):
            version = line.replace("Version: ", "")
            break

    return version


def detect_version_change(client, userdata, msg):
    current_version = userdata["CURRENT_VERSION"]
    try:
        next_version = get_version()

        if next_version and current_version != next_version:
            LOGGER.info(f"Upgraded c8y-xmas-plugin from %s to %s", current_version, next_version)
            client.publish('tedge/events/software_monitor', json.dumps({
                "text": f"Upgraded c8y-xmas-plugin from {current_version} to {next_version}",
                "type": "xmas_plugin_update",
            }))

        userdata["CURRENT_VERSION"] = next_version
                
    except Exception as ex:
        LOGGER.error("Unexpected error. %s", ex, exc_info=True)


if __name__ == "__main__":
    client = mqtt_client.Client(client_id)
    LOGGER.setLevel(logging.INFO)
    LOGGER.info("Starting up xmas software change listener")

    client.on_message = detect_version_change
    client.connect(broker, port)
    client.user_data_set({
        "CURRENT_VERSION": get_version(),
    })

    ## Subscribing to the topic for the jwt token
    client.subscribe('tedge/commands/req/software/update')

    client.loop_forever()
