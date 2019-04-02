# Sort-of-simple-but-not-actually-that-simple Inventory Save System

This script provides a lightweight system for saving/loading players' inventories between sessions automatically. 

Specifically, it provides the option to load the saved loadout when the player connects, and save their current loadout on disconnect. 

## TODO

* Function to add save/load actions to objects
* Handler for mission end

## POSSIBLE ISSUES

* like a whole bunch, I haven't been able to test this yet :|

## Installation

This script requires [iniDBI2](https://github.com/code34/inidbi2) to be runnning on the server/host. 

Add it to your mission by copying the "cupinv" folder. Then initialise it with the following command in your init.sqf:

`[<db name>, <load on join>, <save on quit>, <add force save command>] call compile preproccessfilelinenumbers "cupinv\invInit.sqf";`

The parameters are as follows:-

* "db name": Required, must be a string. The name of your database, defining the file to which the inventories will be saved. If you have multiple missions with the same db name, they will share inventories. 
* "load on join": Optional, boolean, defaults to true. If true, players' saved inventories will automatically load when they first spawn. 
* "save on quit": Optional, boolean, defaults to false. If true, players' inventories will be automatically saved when they disconnect. 
* "add force save command": Optional, boolean, defaults to false. If true, adds an admin-only action that saves all players' current inventories. 