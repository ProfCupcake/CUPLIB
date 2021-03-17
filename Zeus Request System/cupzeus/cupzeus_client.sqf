CUPZEUS_doRequestZeus = 
{
	CUPZEUS_requestZeus = player;
	publicVariableServer "CUPZEUS_requestZeus";
};

CUPZEUS_doRelinquishZeus = 
{
	CUPZEUS_relinquishZeus = player;
	publicVariableServer "CUPZEUS_relinquishZeus";
};

CUPZEUS_requestCondition = 
{
	(isNil {getAssignedCuratorLogic player})
};

CUPZEUS_addRequestAction = 
{
	params ["_object", ["_requestText", "Request Zeus"], ["_relinquishText", "Relinquish Zeus"]];
	_object addAction [_requestText, CUPZEUS_doRequestZeus, nil, 1.5, true, true, "", "call CUPZEUS_requestCondition"];
	_object addAction [_relinquishText, CUPZEUS_doRelinquishZeus, nil, 1.5, true, true, "", "!(call CUPZEUS_requestCondition)"];
};

CUPZEUS_doRequestList = 
{
	CUPZEUS_requestList = player;
	publicVariableServer "CUPZEUS_requestList";
};

CUPZEUS_addListAction = 
{
	params ["_object", ["_listText", "List Current Zeus Operators"]];
	_object addAction [_listText, CUPZEUS_doRequestList, nil, 1.5, true, true, "true"];
};

CUPZEUS_sendAdminResponse = 
{
	params ["", "", "", "_response"];
	_response params ["_unit", "_grant"];
	CUPZEUS_adminResponse = _response;
	publicVariableServer "CUPZEUS_adminResponse";
	player removeAction (CUPZEUS_actionMapGrant get (str _unit));
	player removeAction (CUPZEUS_actionMapDeny get (str _unit));
};

CUPZEUS_handleAdminRequest = 
{
	params ["", "_unit"];
	if (isNil "CUPZEUS_actionMapGrant") then
	{
		CUPZEUS_actionMapGrant = createHashMap;
		CUPZEUS_actionMapDeny = createHashMap;
	};
	systemChat format ["%1 is requesting Zeus...", name _unit];
	if (isNil {CUPZEUS_actionMapGrant get (str _unit)}) then
	{
		CUPZEUS_actionMapGrant set [str _unit, player addAction [format ["Grant %1 Zeus", name _unit], CUPZEUS_sendAdminResponse, [_unit, true], 1.5, true, true, "", "true"]];
		CUPZEUS_actionMapDeny set [str _unit, player addAction [format ["Deny %1 Zeus", name _unit], CUPZEUS_sendAdminResponse, [_unit, false], 1.5, true, true, "", "true"]];
	};
};

"CUPZEUS_adminRequest" addPublicVariableEventHandler CUPZEUS_handleAdminRequest;

CUPZEUS_handleRespawn = 
{
	CUPZEUS_respawnRequest = _this;
	publicVariableServer "CUPZEUS_respawnRequest";
};

CUPZEUS_handleClientRespawnEH = 
{
	params ["", "_add"];
	if (_add) then
	{
		player setVariable ["CUPZEUS_respawnEH", player addEventHandler ["Respawn", CUPZEUS_handleRespawn]];
	} else
	{
		player removeEventHandler ["Respawn", player getVariable "CUPZEUS_respawnEH"];
	};
};

"CUPZEUS_clientRespawnEH" addPublicVariableEventHandler CUPZEUS_handleClientRespawnEH;