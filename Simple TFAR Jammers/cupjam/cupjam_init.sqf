// Exponent for jamming distance scaling
CUPJAM_distanceExponent = 2;

//////////////////////////////////////////////////////////////

call compile preprocessfilelinenumbers "cupjam\cupjam_funcs.sqf";

[] spawn CUPJAM_tickLoop;