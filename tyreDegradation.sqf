/**
	tyreDegradation.sqf
	by Professor Cupcake
	
	Causes constant damage to a vehicle's wheels when it is travelling at speed, relative to its speed. 
	
	Format:-
	
	[vehicle, maxDamage, minSpeed, maxDegradeSpeed, maxDegradeRate, hitPoints] call compile preprocessfilelinenumbers "tyreDegradation.sqf";
	
	Parameters:-
	vehicle - Required - the vehicle which will be affected by the script. 
	
	maxDamage - Optional - number between 0 and 1, defining the maximum damage this script can inflict. Set to 1 or above to allow the script to completely destroy wheels; 0 or below effectively disables the script.
	
	minSpeed - Optional - the minimum speed in km/h before the script starts applying damage.
	
	maxDegradeSpeed - Optional - the speed in km/h at which damage is at its maximum rate. 
	
	maxDegradeRate - Optional - maximum rate of damage to wheels per second. Recommended to set this by dividing the max damage by the desired time to max damage (e.g. 0.7/600 to do 0.7 damage in 10 minutes).
	
	hitPoints - Optional - array of strings defining the hitPoint names for this vehicle's wheels. You may need to change this depending on the vehicle you're using (e.g. modded vehicles with different hitpoint name conventions or vehicles with more or less than 4 wheels). 
	
	
	Defaults for all optional parameters can be viewed and altered in the below "params" call, if desired. 
	
	This script returns the handle for the CBA per-frame handler it creates. If desired, you can use this handle to remove the script with CBA_fnc_removePerFrameHandler.
	
	The script also automatically removes itself if it cannot find the vehicle (i.e. the vehicle has been deleted).
**/

params ["_vehicle", 
		["_maxDamage", 0.7], 
		["_minSpeed", 20], 
		["_maxDegradeSpeed", 80], 
		["_maxDegradeRate", 0.7/600],
		["_hitPoints", ["wheel_1_1_steering", "wheel_1_2_steering", "wheel_2_1_steering", "wheel_2_2_steering"]]
];

_handle = [{
	params ["_args", "_handle"];
	_args params ["_vehicle", "_maxDamage", "_minSpeed", "_maxDegradeSpeed", "_maxDegradeRate", "_hitPoints"];
	if (isNull _vehicle) then
	{
		[_handle] call CBA_fnc_removePerFrameHandler;
	} else
	{
		if (local _vehicle) then
		{
			if (isTouchingGround _vehicle) then
			{
				_speed = (vectorMagnitude (velocity _vehicle)) * 3.6;
				if (_speed > _minSpeed) then
				{
					_degradeAmountThisFrame = (1 min ((_speed-_minSpeed)/(_maxDegradeSpeed-_minSpeed))) * diag_deltaTime * _maxDegradeRate;
					{
						private ["_currentDamage", "_newDamage"];
						_currentDamage = _vehicle getHit _x;
						if (_currentDamage < _maxDamage) then
						{
							_newDamage = (_currentDamage + _degradeAmountThisFrame) min _maxDamage;
							_vehicle setHit [_x, _newDamage];
						};
					} forEach _hitPoints;
				};
			};
		};
	};
}, 0, [_vehicle, _maxDamage, _minSpeed, _maxDegradeSpeed, _maxDegradeRate, _hitPoints]] call CBA_fnc_addPerFrameHandler;

_handle 