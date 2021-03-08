// Sets whether signals are attenuated based on direction (i.e. stronger if looking towards signal)
CUPSIGNAL_directional = true;

// Maximum angle off signal before signal disappears, in degrees. 
// Note: this is angle either way, so the effective arc of signal visibility is actually double this
CUPSIGNAL_maxAngle = 60;

// HashMap that defines the frequency ranges for each antenna type
// key is the classname of the antenna, values are an array: [minimum, maximum]
CUPSIGNAL_freqRanges = createHashMapFromArray [["muzzle_antenna_01_f",[78,89]], ["muzzle_antenna_02_f",[390,500]], ["muzzle_antenna_03_f",[433,433]]];
//For reference:-
// antenna 01 = military
// antenna 02 = experimental
// antenna 03 = jamming

// If the antenna cannot be found in the above HashMap, default to this frequency range
CUPSIGNAL_defaultFreqRange = [78,89];

///////////////////////////////////////////////////////////////////////////////////////////

missionNamespace setVariable ["#EM_Transmit", false];
missionNamespace setVariable ["#EM_FMin", 78];
missionNamespace setVariable ["#EM_FMax", 89];
missionNamespace setVariable ["#EM_SMin", 0];
missionNamespace setVariable ["#EM_SMax", 100];
missionNamespace setVariable ["#EM_SelMin", 0];
missionNamespace setVariable ["#EM_SelMax", 0.1];

call compile preprocessfilelinenumbers "cupsignal\cupsignal_funcs.sqf";

[] spawn CUPSIGNAL_tickLoop;