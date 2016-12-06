//PARAMETERS
///////////////////////////

CUPTRACK_logging = true; // CUPTRACK outputs rather extensively to the RPT file. Set this to false to disable it. 
CUPTRACK_updateDelay = 10; // Time, in seconds, between marker updates

//////////////////////////

// Note: if, for some reason, you want to break the tracking loop, set this variable to false in your code. 
CUPTRACK_tracking = true;
// To restart tracking, you will need to set this to true again and then spawn CUPTRACK_trackLoop.
// Be sure to wait at least the time of the delay before you restart it, to ensure that it has actually stopped. 

CUPTRACK_trackArray = [];

call compile preprocessfilelinenumbers "cuptrack\cuptrack_funcs.sqf";

[] spawn CUPTRACK_trackLoop;

if CUPTRACK_logging then {diag_log format ["[%1] CUPTRACK init complete", time];};