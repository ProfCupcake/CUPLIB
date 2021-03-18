// List of allowed curators
// Can be:-
// - units as variables
// - unit variables as a string (recommended)
// - player UIDs
CUPZEUS_curatorList = [];

// Message display setting
// If 0, no messages are displayed
// If 1, messages are displayed only to player who requested/relinquished zeus
// If 2, messages are displayed to all players
CUPZEUS_displayMessages = 2;

// Whether or not the admin request system is enabled
// If true, the logged/voted in admin will receive requests from anyone not on the curator list, which they can then accept or deny
// If this is false, or if there is no admin, they will simply have their request denied
CUPZEUS_adminCanGrant = true;

// Limit how many curators can be active at a time
// Set to 0 or less to disable
CUPZEUS_curatorLimit = 0;

/////////////////////////////////////////////////////////////////////
//END OF PARAMETERS
/////////////////////////////////////////////////////////////////////

CUPZEUS_handleRequest = 
{
	params ["", "_unit"];
	private ["_client", "_uid"];
	_client = owner _unit;
	_uid = getPlayerUID _unit;
	_unitStr = str _unit;
	if ((CUPZEUS_curatorLimit > 0) and 
		{!isNil "CUPZEUS_curatorModuleGroup"} and 
		{((count units CUPZEUS_curatorModuleGroup) - 1) >= CUPZEUS_curatorLimit}) exitWith
	{
		"Denied: Zeus limit reached" remoteExec ["systemChat", _unit];
	};
	if ((_client == 2) or // client is localhost
		{(admin _client) > 0} or // client is admin
		{_unit in CUPZEUS_curatorList} or
		{_unitStr in CUPZEUS_curatorList} or
		{_uid in CUPZEUS_curatorList}) then
	{
		[_unit] call CUPZEUS_grantZeus;
	} else
	{
		if (CUPZEUS_adminCanGrant) then
		{
			private "_admin";
			_admin = call CUPZEUS_findAdmin;
			if !(isNil "_admin") then
			{
				"Sending Zeus request to admin..." remoteExec ["systemChat", _unit];
				[_unit, _admin] call CUPZEUS_sendAdminRequest;
			} else
			{
				[_unit] call CUPZEUS_denyZeus;
			};
		} else
		{
			[_unit] call CUPZEUS_denyZeus;
		};
	};
};

CUPZEUS_grantZeus = 
{
	params ["_unit", ["_displayMessages", CUPZEUS_displayMessages]];
	private ["_respawnEH"];
	[_unit] call CUPZEUS_assignCurator;
	/*
	CUPZEUS_clientRespawnEH = true;
	(owner _this) publicVariableClient "CUPZEUS_clientRespawnEH";
	*/
	_respawnEH = _unit addMPEventHandler ["MPRespawn", {
		//systemChat "respawn EH fired";
		CUPZEUS_respawnRequest = _this;
		publicVariableServer "CUPZEUS_respawnRequest";
	}];
	_unit setVariable ["CUPZEUS_respawnEH", _respawnEH];
	switch (_displayMessages) do
	{
		case 1: {"Zeus granted" remoteExec ["systemChat", _unit];};
		case 2: {(format ["Zeus granted to %1", name _unit]) remoteExec ["systemChat", 0];};
	};
};

/**
Assigns a curator module, creating if necessary, and adds to active group
**/
CUPZEUS_assignCurator = 
{
	params ["_unit"];
	private ["_curator"];
	if ((!isNil "CUPZEUS_inactiveModuleGroup") and {count units CUPZEUS_inactiveModuleGroup > 1}) then
	{
		_curator = ((units CUPZEUS_inactiveModuleGroup) select 1);
		[_curator] joinSilent CUPZEUS_curatorModuleGroup;
	} else
	{
		if (isNil "CUPZEUS_curatorModuleGroup") then 
		{
			CUPZEUS_curatorModuleGroup = createGroup sideLogic;
			CUPZEUS_curatorModuleGroup createUnit ["Logic", _unit, [], 1, "NONE"]; // create dummy unit to prevent group garbage collection
		};
		_curator = CUPZEUS_curatorModuleGroup createUnit ["ModuleCurator_F", _unit, [], 1, "NONE"];
		_curator setVariable ["Addons", 3, true];
	};
	_unit assignCurator _curator;
};

CUPZEUS_denyZeus = 
{
	params ["_unit", ["_displayMessages", CUPZEUS_displayMessages]];
	if (_displayMessages > 0) then
	{
		"Zeus denied" remoteExec ["systemChat", _this];
	};
};

"CUPZEUS_requestZeus" addPublicVariableEventHandler CUPZEUS_handleRequest;

CUPZEUS_handleRelinquish = 
{
	params ["", "_unit"];
	private ["_curator"];
	_curator = getAssignedCuratorLogic _unit;
	unassignCurator _curator;
	_curator call CUPZEUS_attemptModuleDelete;
	/**
	CUPZEUS_clientRespawnEH = false;
	(owner _unit) publicVariableClient "CUPZEUS_clientRespawnEH";
	**/
	_unit removeMPEventHandler ["MPRespawn", _unit getVariable "CUPZEUS_respawnEH"];
	_unit setVariable ["CUPZEUS_respawnEH", nil];
	switch (CUPZEUS_displayMessages) do
	{
		case 1: {"Zeus relinquished" remoteExec ["systemChat", _unit];};
		case 2: {(format ["%1 relinquished Zeus", name _unit]) remoteExec ["systemChat", 0];};
	};
};

"CUPZEUS_relinquishZeus" addPublicVariableEventHandler CUPZEUS_handleRelinquish;

/**
Returns the client ID of logged/voted-in admin, or nil if there is no admin
**/
CUPZEUS_findAdmin = 
{
	private ["_allPlayers", "_admin"];
	if (hasInterface) exitWith {2};
	_allPlayers = allPlayers - (entities "HeadlessClient_F"); 
	{
		if (admin owner _x > 0) then
		{
			_admin = owner _x;
			break;
		};
	} forEach _allPlayers;
	_admin
};

CUPZEUS_sendAdminRequest = 
{
	params ["_unit", "_admin"];
	CUPZEUS_adminRequest = _unit;
	_admin publicVariableClient "CUPZEUS_adminRequest";
};

CUPZEUS_handleAdminResponse = 
{
	params ["", "_response"];
	_response params ["_unit", "_grant", "_admin"];
	if ((admin owner _admin) > 0) then
	{
		if (_grant) then
		{
			"Admin granted request" remoteExec ["systemChat", _unit];
			[_unit] call CUPZEUS_grantZeus;
		} else
		{
			"Admin denied request" remoteExec ["systemChat", _unit];
			[_unit] call CUPZEUS_denyZeus;
		};
	};
};

"CUPZEUS_adminResponse" addPublicVariableEventHandler CUPZEUS_handleAdminResponse;

CUPZEUS_handleRespawnServer = 
{
	//systemChat format ["Respawn request received: %1", _this];
	params ["", "_params"];
	_params params ["_unit", "_corpse"];
	/**
	private "_curator";
	_curator = getAssignedCuratorLogic _corpse;
	unassignCurator _curator; 
	_unit assignCurator _curator;
	**/
	if (!isNil {_corpse getVariable "CUPZEUS_respawnEH"}) then
	{
		[_unit] call CUPZEUS_assignCurator;
		_unit setVariable ["CUPZEUS_respawnEH", _corpse getVariable "CUPZEUS_respawnEH"];
	};
};

"CUPZEUS_respawnRequest" addPublicVariableEventHandler CUPZEUS_handleRespawnServer;

CUPZEUS_handleDisconnect = 
{
	params ["_unit", "_id", "_uid", "_name"];
	if !(isNil "CUPZEUS_curatorModuleGroup") then
	{
		if (getAssignedCuratorLogic _unit in units CUPZEUS_curatorModuleGroup) then
		{
			private "_curator";
			_curator = getAssignedCuratorLogic _unit;
			unassignCurator _curator;
			_curator call CUPZEUS_attemptModuleDelete;
		};
	};
};

addMissionEventHandler ["HandleDisconnect", CUPZEUS_handleDisconnect];

CUPZEUS_handleListRequest = 
{
	params ["", "_unit"];
	if ((isNil "CUPZEUS_curatorModuleGroup") or {(count (units CUPZEUS_curatorModuleGroup)) <= 1}) exitWith
	{
		"No active Zeus operators" remoteExec ["systemChat", _unit];
	};
	"Active Zeus operators:" remoteExec ["systemChat", _unit];
	{
		if (_x isKindOf "ModuleCurator_F") then // only count curator modules (ignore dummy logics)
		{
			(format ["%1", (name (getAssignedCuratorUnit _x))]) remoteExec ["systemChat", _unit];
		};
	} forEach (units CUPZEUS_curatorModuleGroup);
};

"CUPZEUS_requestList" addPublicVariableEventHandler CUPZEUS_handleListRequest;

/**
Attempts to delete Zeus module
If it fails, move Zeus module to inactive group to be re-used later
**/
CUPZEUS_attemptModuleDelete = 
{
	//deleteVehicle _this; // commented out, because it's probably better to just never bother trying to delete them, tbh
	if !(isNull _this) then
	{
		if (isNil "CUPZEUS_inactiveModuleGroup") then
		{
			CUPZEUS_inactiveModuleGroup = createGroup sideLogic;
			CUPZEUS_inactiveModuleGroup createUnit ["Logic", _unit, [], 1, "NONE"]; // create dummy unit to prevent group garbage collection
		};
		_this removeCuratorEditableObjects [curatorEditableObjects _this, true];
		[_this] joinSilent CUPZEUS_inactiveModuleGroup;
	};
};