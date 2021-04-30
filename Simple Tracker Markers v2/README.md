# Dead Simple Tracker Marker Script V2

This script provides an easy solution to tracking units via regularly (but not necessarily often) updating markers. 

The markers are in the form of a dot, with a trailing line. The line extends from the mark's position at the previous update to the current position. This gives you a way to see the distance that has been travelled between marker updates and thus get an idea of the speed your target is moving. 

In addition to backend improvements over the older version, this version now includes the option for multiple line segments. So you can have a curved(-ish) line that follows the path of the unit. 

The markers will be automatically corrected to account for respawns, however they will not remove themselves from units that have died - you'll have to do that yourself if you want that to happen. 

This script requires CBA. 

## Installation

Add it to your mission by copying the "cuptrack" folder into your mission folder, and adding the following to your initPlayerLocal.sqf:

`call compile preprocessfilelinenumbers "cuptrack\cuptrack_init.sqf";`

## Adding a Tracker Marker

The following function will add a tracker marker to a unit:-

`[target, text, colour, width, lineSegments, tickRate] call CUPTRACK_setTrack;`

Note that the markers are local to the client on which the command runs. The parameters are as follows:-

`target` - Required - The unit to be tracked. 

`text` - Optional, default `""` (empty string) - The text on the marker dot. 

`colour` - Optional, default `"Default"` - The colour of the marker and line. 

`width` - Optional, default `2` - The width of the line. 

`lineSegments` - Optional, default `1` - The number of line segments. Each line segment represents the movement between update ticks. Inputs are clamped to a minimum of 1.

`tickRate` - Optional, default `15` - The delay between update ticks, in seconds. Note that setting this to 0 will update the tracker every frame. This is not recommended; if you want real-time updates, use a value like `0.03` (which is ~30 updates per second). 

If desired, all of the above defaults can be changed at the top of `cuptrack_init.sqf`. 

Additionally, there is a helper script for use in the init fields of units in the editor. In this case, running the above command won't work, so you can use this instead:-

`[this, text, colour, width, lineSegments, tickRate] call compile preprocessfilelinenumbers "cuptrack\cuptrack_unitInit.sqf";`

The parameters are the same. 

## Removing a Tracker Marker

Removing a tracker marker is simple:-

`target call CUPTRACK_removeTrack;`

Where `target` is the unit that is (or, was) being tracked. 

## Getting Tracker Parameters

There is also the following function:-

`target call CUPTRACK_getTrack;`

Where `target` is a unit that is being tracked. This will return the tracker parameters for this unit, as they would've been provided on its `setTrack` call. 

It the unit is not being tracked, it returns `nil`. 