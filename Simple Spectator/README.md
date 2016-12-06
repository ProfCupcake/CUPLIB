# Dead Simple Spectator Script

This script features possibly the most basic spectator system in all of Arma. 

It is first-person only. You will see whatever the person you're spectating sees. 

## Installation

Add it to your mission by copying the "cupspec" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cupspec\cupspec_init.sqf";`

## Spectator Controls

The controls are relative to your keybinds. 

Move left - Switch to previous target
Move right - Switch to next target
Reload - Stop spectating

## Initiating Spectator

Currently, there is only one way to initiate the spectator mode: via a spectator object. 

Create a spectator object by running the following:

`[object, range] call CUPSPEC_addSpectatorObject;`

This will add an action to the object, which will put the player into spectator mode. Their character remains in position, and if they are moved too far away from the object (as defined by the 'range' parameter), they will be automatically kicked out of spectator mode. 