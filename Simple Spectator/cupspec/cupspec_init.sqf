if (isDedicated) exitWith {};

CUPSPEC_actionColour = "#ffb000";

CUPSPEC_customCondition = _this;

waitUntil {player == player};

CUPSPEC_spectating = nil;
call compile preprocessfilelinenumbers "cupspec\cupspec_funcs.sqf";
disableSerialization;
//"CUPSPEC_control" addPublicVariableEventHandler [CUPSPEC_controlEH];
waituntil {!(IsNull (findDisplay 46))};
(findDisplay 46) displayAddEventHandler ["keyUp", "_this call CUPSPEC_inputEH;"];