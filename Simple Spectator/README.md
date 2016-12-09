# Dead Simple Spectator Script

This script features possibly the most basic spectator system in all of Arma. 

It is first-person only. You will see whatever the person you're spectating sees. 

### TODO

* Restrictions
	* group
	* side
	* custom
* Alternate Initiations
	* upon death (can be permanent or temporary)
	* arbitrarily callable function
* Handling situations
	* Spectator target dies
		* Run switch target function? That should handle everything just fine. 
	* I think that's basically the only situation that needs to be handled... right? Right? Right. 
* View modes
	* Standard third-person
	* Scripted third-person (to override difficulty setting restrictions)
	* Investigate possibility of having zoom, vision modes (NV, IR), and whatnot available relative to target's equipment

## Installation

Add it to your mission by copying the "cupspec" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cupspec\cupspec_init.sqf";`

## Spectator Controls

The controls are relative to your keybinds. 

* Move left - Switch to previous target
* Move right - Switch to next target
* Reload - Stop spectating

## Initiating Spectator

Currently, there is only one way to initiate the spectator mode: via a spectator object. 

Create a spectator object by running the following:

`[object, range] call CUPSPEC_addSpectatorObject;`

This will add an action to the object, which will put the player into spectator mode. Their character remains in position, and if they are moved too far away from the object (as defined by the 'range' parameter), they will be automatically kicked out of spectator mode. 