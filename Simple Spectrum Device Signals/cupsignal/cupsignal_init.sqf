// Sets whether signals are attenuated based on direction (i.e. stronger if looking towards signal) by default
CUPSIGNAL_directional = true;

// Whether or not signals are simulated in 3D; if false, height is ignored
CUPSIGNAL_3D = true;

// Maximum angle off signal before signal disappears, in degrees
// Actual visible angle is double this (think radius vs diameter)
CUPSIGNAL_maxAngle = 60;

// Default maximum range for newly-created signals, in metres
CUPSIGNAL_defaultMaxRange = 500;

// Default minimum range for newly-created signals, in metres
CUPSIGNAL_defaultMinRange = 5;

// Default angle for conical signals
CUPSIGNAL_defaultConeAngle = 60;

// Defines the width of the frequency selector, in MHz
CUPSIGNAL_selectionWidth = 1;

// HashMap that defines the frequency ranges for each antenna type
// key is the classname of the antenna, values are an array: [minimum, maximum]
CUPSIGNAL_freqRanges = createHashMapFromArray [
	["muzzle_antenna_01_f", [78, 89]], // military antenna
	["muzzle_antenna_02_f", [390, 500]], // experimental antenna
	["muzzle_antenna_03_f", [433 - (CUPSIGNAL_selectionWidth/2), 433 + (CUPSIGNAL_selectionWidth/2)]]]; //jamming antenna (set so that it selects 433 only by defaulk)

// If the antenna cannot be found in the above HashMap, default to this frequency range
CUPSIGNAL_defaultFreqRange = [78,89];

// Max range of Spectrum Device transmit mode signal, in metres
CUPSIGNAL_transmitMaxRange = 100;

// Min range of transmit
CUPSIGNAL_transmitMinRange = 1;

// Angle of transmission cone
CUPSIGNAL_transmitAngle = 60;

// Exponent for strength over distance. 
// At 1, strength is adjusted linearly over distance. 
// Values higher than 1 will cause signals to get stronger quicker the closer you get. (e.g. from 200m -> 100m will be a greater increase in signal strength than 300m -> 200m)
// Values between 0 and 1 will have the opposite effect. 
// Values below 0 may break things, but if it doesn't break it'll reverse signal strengths (further = stronger and vice-versa). Not recommended for anything other than goofing around. 
CUPSIGNAL_distanceExponent = 1;

// Same as above, but for direction
CUPSIGNAL_directionExponent = 2;

// Delay between script updates, in seconds
// Increase for slightly better performance, decrease for quicker response to movement etc.
CUPSIGNAL_tickDelay = 0.1;

// Maximum strength of signals. Doesn't really change anything other than the numbers shown on the Spectrum display. 
// This may break things if set to a value below 0. 
CUPSIGNAL_maxStrength = 100;

// When true, enables debug output
CUPSIGNAL_debug = false;

///////////////////////////////////////////////////////////////////////////////////////////

CUPSIGNAL_maxAngleVM = CUPSIGNAL_maxAngle/90;

missionNamespace setVariable ["#EM_Transmit", false];
missionNamespace setVariable ["#EM_FMin", 0];
missionNamespace setVariable ["#EM_FMax", 0];
missionNamespace setVariable ["#EM_SMin", 0];
missionNamespace setVariable ["#EM_SMax", CUPSIGNAL_maxStrength];
missionNamespace setVariable ["#EM_SelMin", 0];
missionNamespace setVariable ["#EM_SelMax", CUPSIGNAL_selectionWidth];

call compile preprocessfilelinenumbers "cupsignal\cupsignal_funcs.sqf";

[] spawn CUPSIGNAL_tickLoop;