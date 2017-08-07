# boxerino

Boxerino is a tool to assist in managing vagrant boxes in a self hosted
repository. Its main purpose is to edit the .json file that lists all
available versions. You can upload, list, and delete boxes from your repo.

The directory structure ist currently limited to what we use at CORE4 but I am
happy to help you if you want to use it.

## Limitations
* You have to set up your own server to use this tool. You cannot manage the
global vagrant repository with boxerino.
* Currently, boxerino does not add new configurations. You can only
upload more boxes to an existing one.

## Usage
* *boxerino help* will display a list of available commands and parameters
* *boxerino list* will display all available box and each current version
* *boxerino upload \<name\> \<version\>* lets you upload a packaged box the the server
* *boxerino delete \<name\> \<version\>* lets you delete a version of a box

