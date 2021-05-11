# Dead Simple TFAR Antenna Rigging Script

A script that allows you to go to any antenna on any terrain and jury-rig it into a TFAR relay antenna. 

This requires the TFAR beta build. 

It will add a hold-action to all antennae on the map, requiring some amount of time to rig up the antenna. After using this action, the antenna is considered "rigged", and can be enabled/disabled at will. 

Note that some larger antenna may require you to climb up them a bit before you count as close enough to access their actions. This wasn't intentional, but is a nice little sorta immersive part of the script, so it's staying that way. 

## Installation

Add it to your mission by copying the "cuprig" folder, and running the following on mission start on the server (e.g. in `initServer.sqf`, or inside an `isServer` block in `init.sqf`):

`call compile preprocessfilelinenumbers "cuprig\cuprig_init.sqf"`

And that's it. It will automatically add actions to every radio mast and other such structure in the world. 

You can customise its behaviour by changing some of the variables at the top of `cuprig_init.sqf`. Particularly, you may want to pay attention to the blacklist; some maps have structures that may be detected as antennae but which shouldn't really count for the purposes of this script (such as the radar domes, which are blacklisted by default). 

## Manual Antenna Setup

You can also manually add the actions to any object you like, turning it into a "riggable" antenna, by running the following command:

`[target, range, rigTime] call CUPRIG_addRigActions;`

Make sure you run it on one machine only (ideally the server). The parameters are as follows:-

`target` is the only required parameter. It is the object to which the actions will be attached, and which will become the radio relay if the players activate it. 

`range` is the range of the relay once activated, in metres. It is optional, defaulting to the default range set in `cuprig_init.sqf` (which, in turn, is 50km by default).

`rigTime` is the time taken for the rigging of the antenna, in seconds. As above, it is optional and the default is set in `cuprig_init.sqf` (15s by default).
