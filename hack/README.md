# Remote trigger

* Trigger any number of functions from the  cloud
    * E.g. trigger vending machine dispatch without the QR code reader

    => Custom operation which includes
    => Package

* Analytics
    * Counter - eg. when a QR code is scanned
    * Tilt alarm (when someone is doing something that they should not be doing)
    * Low stock alarm - Trigger email to indicate that more 
    => UI to display the current count and any alarms
    => Send an email

* Logging
    * Collect debug
    * 


# Deploying the package

1. Update the `c8y-configuration-plugin` to add some new versions

2. Apply the `apt-extension` configuration which points to the custom apt repository

3. Install the software `c8y-xmas-plugin` and `c8y-remoteaccess-plugin`

4. Send a command

    ```sh
    # dispatch
    c8y operations create --device snack-calendar --template "{c8y_Command:{text: 'dispatch'}}"

    # play sound
    c8y operations create --device snack-calendar --template "{c8y_Command:{text: 'play_sounds'}}"

    # unknown command
    c8y operations create --device snack-calendar --template "{c8y_Command:{text: 'unknown'}}"
    ```
