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
CUPJAM_tickDelay = 0.03;

// Whether or not to use CBA per-frame event handlers
// If true, will use CBA per-frame handlers for loops
// If false, will use a manual delay loop
// If nil, will automatically set itself to true if CBA is installed or false if not. 
CUPJAM_CBA = nil;

// Defines whether the tickDelay is used when CBA per-frame handlers are enabled
// If true, script will be delayed by tickDelay as it is without CBA
// If false, script will run every frame with CBA
CUPJAM_CBA_useTickDelay = false;

//////////////////////////////////////////////////////////////

call compile preprocessfilelinenumbers "cupjam\cupjam_funcs.sqf";

if (isNil "CUPJAM_CBA") then
{
	CUPJAM_CBA = !isNil "CBA_fnc_addPerFrameHandler";
};

if (CUPJAM_CBA) then
{
	[CUPJAM_tick, ([0, CUPJAM_tickDelay] select CUPJAM_CBA_useTickDelay)] call CBA_fnc_addPerFrameHandler;
} else
{
	[] spawn CUPJAM_tickLoop;
};