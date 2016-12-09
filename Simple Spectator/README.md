# Dead Simple Spectator Script

This script features possibly the most basic spectator system in all of Arma. 

It is first-person only. You will see whatever the person you're spectating sees. 

### TODO

* Alternate Initiations
	* upon death (can be permanent or temporary)
	* arbitrarily callable function
* Handling situations
	* Spectator target dies
		* Run switch target function? That should handle everything just fine. 
	* I think that's basically the only situation that needs to be handled... right? Right? Right. 
* View modes
	* Standard third-person (Might be possible already - test this)
	* Scripted third-person (to override difficulty setting restrictions)
	* Investigate possibility of having zoom, vision modes (NV, IR), and whatnot available relative to target's equipment

## Installation

Add it to your mission by copying the "cupspec" folder into your mission folder, and adding the following to your init.sqf:

`{true} call compile preprocessfilelinenumbers "cupspec\cupspec_init.sqf";`

You can optionally define a custom condition, by replacing the parameter with a function that returns true or false. Any other return will throw an error. More detail on this is provided further down this page, as well as some useful presets. 

## Spectator Controls

The controls are relative to your keybinds. 

* Move left - Switch to previous target
* Move right - Switch to next target
* Reload - Stop spectating

## Initiating Spectator

Currently, there is only one way to initiate the spectator mode: via a spectator object. 

Create a spectator object by running the following:

`[object, <range>] call CUPSPEC_addSpectatorObject;`

This will add an action to the object, which will put the player into spectator mode. Their character remains in position, and if they are moved too far away from the object (as defined by the 'range' parameter), they will be automatically kicked out of spectator mode. Specifying the range is option; it will default to 25m.

## Custom Condition

The custom condition is a method of checking whether potential spectator targets are allowed in your mission. It has one argument: the unit being checked. It should return either true or false, with true meaning that the target is allowed to be spectated. Any other return value will cause errors. 

It is defined as a piece of code upon initialisation, as mentioned above. The above example is the simplest it can get: it will just indiscriminately accept everyone. Below are some examples of more restrictive conditions. 

### Restrict to Player Side

`{(side player == side _this)} call compile preprocessfilelinenumbers "cupspec\cupspec_init.sqf";`

### Restrict to Player Group

`{(group player == group _this)} call compile preprocessfilelinenumbers "cupspec\cupspec_init.sqf";`

### Restrict to Player's Group Leader

`{(_this == leader player)} call compile preprocessfilelinenumbers "cupspec\cupspec_init.sqf";`

### Restrict to a Specific Player via their UID

I'm not sure why you would ever want to do this, but what the hey.

`{(getPlayerUID = "1234567890")} call compile preprocessfilelinenumbers "cupspec\cupspec_init.sqf";`

... And so on. Either you understand this by now, and can write one of these perfectly fine, or you don't, in which case you can just copy one of the above and use that. 