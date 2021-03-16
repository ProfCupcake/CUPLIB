// Exponent for jamming distance scaling
CUPJAM_distanceExponent = 2;

// Toggles CUPSIGNAL integration
// When true, jammers will have a signal placed on them via CUPSIGNAL
// Obviously, this requires CUPSIGNAL to be installed and activated before you add any jammers
CUPJAM_signalSupport = false;
// Note that changing this mid-mission does not apply it retroactively

// If CUPSIGNAL support is enabled, the jammer signals will be on the following frequency
CUPJAM_signalFrequency = 433;

// If CUPSIGNAL support is enabled, the minimum range of the signal will be equal to the minimum range of the jammer multiplied by the following
CUPJAM_signalMinRangeMult = 0.5;

// As above, but for maximum range
CUPJAM_signalMaxRangeMult = 2;

// Delay between script updates, in seconds
// Increase for slightly better performance, decrease for quicker response to movement etc.
CUPJAM_tickDelay = 0.1;

//////////////////////////////////////////////////////////////

call compile preprocessfilelinenumbers "cupjam\cupjam_funcs.sqf";

[] spawn CUPJAM_tickLoop;