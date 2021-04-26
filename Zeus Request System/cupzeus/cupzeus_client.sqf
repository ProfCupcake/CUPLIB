// Delay until list action is available after use, in seconds
// To avoid spamming server with list requests
CUPZEUS_listDelay = 2;

// Delay until request action is available after use, in seconds
// To avoid spamming server and/or admin with list requests
CUPZEUS_requestDelay = 10;

//////////////////////////////////////////////////////////////

CUPZEUS_requestTimeout = 0;

CUPZEUS_listTimeout = 0;

CUPZEUS_doRequestZeus = 
{
	player remoteExec ["CUPZEUS_handleRequest", 2];
	CUPZEUS_requestTimeout = time + CUPZEUS_requestDelay;
};

CUPZEUS_doRelinquishZeus = 
{
	player remoteExec ["CUPZEUS_handleRelinquish", 2];
};

CUPZEUS_requestCondition = 
{
	if (CUPZEUS_requestTimeout > time) then
	{
		false
	} else
	{
		isNull (getAssignedCuratorLogic player)
	};
};

CUPZEUS_relinquishCondition = 
{
	!isNull (getAssignedCuratorLogic player)
};

CUPZEUS_addRequestAction = 
{
	params ["_object", ["_requestText", "Request Zeus"], ["_relinquishText", "Relinquish Zeus"]];
	_object addAction [_requestText, CUPZEUS_doRequestZeus, nil, 1.5, true, true, "", "call CUPZEUS_requestCondition"];
	_object addAction [_relinquishText, CUPZEUS_doRelinquishZeus, nil, 1.5, true, true, "", "call CUPZEUS_relinquishCondition"];
};

CUPZEUS_doRequestList = 
{
	player remoteExec ["CUPZEUS_handleListRequest", 2];
	CUPZEUS_listTimeout = time + CUPZEUS_listDelay;
};

CUPZEUS_listCondition = 
{
	if (CUPZEUS_listTimeout > time) then
	{
		true
	} else
	{
		false
	};
};

CUPZEUS_addListAction = 
{
	params ["_object", ["_listText", "List Current Zeus Operators"]];
	_object addAction [_listText, CUPZEUS_doRequestList, nil, 1.5, true, true, "call CUPZEUS_listCondition"];
};

CUPZEUS_sendAdminResponse = 
{
	params ["", "", "", "_response"];
	_response params ["_unit", "_grant"];
	[_unit, _grant, player] remoteExec ["CUPZEUS_handleAdminResponse", 2];
	player removeAction (CUPZEUS_actionMapGrant get (str _unit));
	player removeAction (CUPZEUS_actionMapDeny get (str _unit));
};

CUPZEUS_handleAdminRequest = 
{
	_unit = _this;
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

CUPZEUS_handleKilled = 
{
	if (isServer) then
	{
		params ["_unit"];
		if !(isNil "CUPZEUS_curatorModuleGroup") then
		{
			private "_curator";
			_curator = getAssignedCuratorLogic _unit;
			if (_curator in (units CUPZEUS_curatorModuleGroup)) then
			{
				_unit setVariable ["CUPZEUS_curatorObjects", curatorEditableObjects _curator];
				unassignCurator _curator;
				_curator call CUPZEUS_attemptModuleDelete;
			};
		};
	};
};

player addMPEventHandler ["MPKilled", CUPZEUS_handleKilled]; 

player addMPEventHandler ["MPRespawn", {_this remoteExec ["CUPZEUS_handleRespawnServer", 2];}];