/*
Script to generate a random position, within the bounds of a marker. 

Input: marker name. 
Output: position, technically in 3D form, but the z-coord is always 0.

position = "markerName" call compile preprocessfilelinenumbers "randomPosInMarker.sqf";

by Professor Cupcake
*/

_return = [0,0,0];
if (markerShape _this == "ICON") then {_return = markerPos _this;}
else
{
	_dispVector = [0,0];
	if (markerShape _this == "RECTANGLE") then
	{
		_dispVector = [(random 2) - 1, (random 2) - 1]; //Generate displacement from centre of unit square
	};
	if (markerShape _this == "ELLIPSE") then
	{
		_direction = random 360; //Generate direction to move from centre
		_distance = random 1; //Generate distance from centre of unit circle
		_dispVector = [sqrt(_distance)*cos(_direction), sqrt(_distance)*sin(_direction)]; //Get displacement in unit circle, as defined by above distance/direction
	};
	_size = markerSize _this;
	_dispVector = [(_dispVector select 0)*(_size select 0), (_dispVector select 1)*(_size select 1)]; //Scale to size of marker
	_angle = -(markerDir _this);
	//Rotate (via matrix/vector rotation) to fit marker
	//Also adds the z-coord (0)
	_dispVector = [((cos _angle)*(_dispVector select 0)) - ((sin _angle)*(_dispVector select 1)), ((sin _angle)*(_dispVector select 0)) + ((cos _angle)*(_dispVector select 1)),0];
	
	_return = (markerPos _this) vectorAdd (_dispVector); //Add displacement to marker pos to get final position
};

if (markerShape _this == "POLYLINE") then {diag_log "You're a monster.";};

_return