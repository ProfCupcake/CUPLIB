/**
call compile preprocessfilelinenumbers "cupinv\playerInit.sqf";

CUP_invSaveAction = thebox addAction ["<t color='#ff0000'>Save loadout</t>", {publicVariableServer "saveRequest";}, nil, 3, true, true, "", "true"];
CUP_invLoadAction = thebox addAction ["<t color='#ff0000'>Load saved loadout</t>", {publicVariableServer "invRequest";}, nil, 2, false, true, "", "true"];
**/

// Deprecated