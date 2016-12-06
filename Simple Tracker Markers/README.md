# Dead Simple Tracker Marker Script

This script provides an easy solution to tracking units via regularly (but not necessarily often) updating markers. 

The markers are in the form of a dot, with a trailing line. The line extends from the mark's position at the previous update to the current position. This gives you a way to see the distance that has been travelled between marker updates and thus get an idea of the speed your target is moving. 

The markers will be automatically corrected to account for respawns, however they will not remove themselves from units that have died - you'll have to do that yourself if you want that to happen. 

## Installation

Add it to your mission by copying the "cuptrack" folder into your mission folder, and adding the following to your init.sqf:

`call compile preprocessfilelinenumbers "cuptrack\cuptrack_init.sqf";`

## Adding a Tracker Marker

The following function will add a tracker marker to a unit:-

`[target, text, colour, width] call CUPTRACK_addTrack;`

The "target" parameter is the unit to be tracked. It is the only required parameter. 
The "text" parameter defines the text to be displayed on the marker, or lack thereof, if you set it to an empty string. Defaults to nothing.
The "colour" parameter defines the colour of the mark and line. This must be one of the marker colour strings. Defaults to "ColourBlack". 
The "width" parameter defines the width of the line following the dot. This is in metres, and will be scaled as such on the map. Defaults to 2. 

Trying to add multiple tracker markers to the same unit won't work - the new track's marks will just replace the old one. It will still make a new entry though, which will make removing the mark rather annoying. 

## Removing a Tracker Marker

The following function will remove a tracker marker from a unit:-

`target call CUPTRACK_removeTrack;`