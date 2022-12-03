local action = var("action", "install");
local name = var("name");
local version = var("version", "");

{
    "description": action + " software " + name,
    "c8y_SoftwareUpdate": [
        {
            "action": action,
            "name": name,
            "url": "",
            "version": version,
        }
    ]
}