// List of allowed curators
// Can be:-
// - units as variables
// - unit variables as a string (recommended)
// - player UIDs
CUPZEUS_curatorList = [];

// List of specifically disallowed curators
// Only useful if either "adminCanGrant" or "openMode" is true. 
// In either case, units or players in this list will be automatically rejected
CUPZEUS_curatorBlacklist = [];

// Message display setting
// If 0, no messages are displayed
// If 1, messages are displayed only to player who requested/relinquished zeus
// If 2, messages are displayed to all players
CUPZEUS_displayMessages = 2;

// Whether or not the admin request system is enabled
// If true, the logged/voted in admin will receive requests from anyone not on the curator list, which they can then accept or deny
// If this is false, or if there is no admin, they will simply have their request denied
CUPZEUS_adminCanGrant = true;

// If true, curator is completely open to anybody
CUPZEUS_openMode = false;

// Limit how many curators can be active at a time
// Set to 0 or less to disable
CUPZEUS_curatorLimit = 0;

/////////////////////////////////////////////////////////////////////
//END OF PARAMETERS
/////////////////////////////////////////////////////////////////////

CUPZEUS_curatorObjectsUIDMap = createHashMap;

// Checks given list for the given unit/player in the following formats:-
// - raw variable
// - variable name as a string
// - player UID as a string
// - player UID as a number
CUPZEUS_checkList = 
{
	params ["_unit", "_list"];
	
	if (_unit in _list) exitWith {true};
	
	if (str _unit in _list) exitWith {true};
	
	if (getPlayerUID _unit in _list) exitWith {true};
	
	if (parseNumber getPlayerUID _unit in _list) exitWith {true};
	
	false
};

CUPZEUS_handleRequest = 
{
	_unit = _this;
	_client = owner _unit;
	if ([_unit, CUPZEUS_curatorBlacklist] call CUPZEUS_checkList) exitWith
	{
		[_unit, nil, ": you are blacklisted from Zeus"] call CUPZEUS_denyZeus;
	};
	
	if ((CUPZEUS_curatorLimit > 0) and 
		{!isNil "CUPZEUS_curatorModuleGroup"} and 
		{((count units CUPZEUS_curatorModuleGroup) - 1) >= CUPZEUS_curatorLimit}) exitWith
	{
		[_unit, nil, ": Zeus limit reached"] call CUPZEUS_denyZeus;
	};
	
	if (CUPZEUS_openMode) exitWith
	{
		[_unit, nil, ": open Zeus"] call CUPZEUS_grantZeus;
	};
	
	if (_client == 2) exitWith
	{
		[_unit, nil, ": server host"] call CUPZEUS_grantZeus;
	};
	
	if ((admin _client) > 0) exitWith
	{
		[_unit, nil, ": admin"] call CUPZEUS_grantZeus;
	};
	
	if ([_unit, CUPZEUS_curatorList] call CUPZEUS_checkList) exitWith
	{
		[_unit, nil, ": on allowed Zeus list"] call CUPZEUS_grantZeus;
	};
	
	if ((CUPZEUS_adminCanGrant)) then
	{
		private "_admin";
		_admin = call CUPZEUS_findAdmin;
		if !(isNil "_admin") then
		{
			"Sending Zeus request to admin..." remoteExec ["systemChat", _unit];
			[_unit, _admin] call CUPZEUS_sendAdminRequest;
		} else
		{
			[_unit, nil, ": you are not on the allowed Zeus list"] call CUPZEUS_denyZeus;
		};
	} else
	{
		[_unit, nil, ": you are not on the allowed Zeus list"] call CUPZEUS_denyZeus;
	};
};

CUPZEUS_grantZeus = 
{
	params ["_unit", ["_displayMessages", CUPZEUS_displayMessages], ["_reason", ""]];
	private ["_respawnEH"];
	[_unit] call CUPZEUS_assignCurator;
	_unit setVariable ["CUPZEUS_isCurator", true];
	
	switch (_displayMessages) do
	{
		case 1: {(format ["Zeus granted%1", _reason]) remoteExec ["systemChat", _unit];};
		case 2: {(format ["Zeus granted to %1%2", name _unit, _reason]) remoteExec ["systemChat", 0];};
	};
};

/**
Assigns a curator module, creating if necessary, and adds to active group
Returns assigned curator module
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
	if (!isNil {_unit getVariable "CUPZEUS_curatorObjects"}) then
	{
		_curator addCuratorEditableObjects [_unit getVariable "CUPZEUS_curatorObjects"];
	} else
	{
		if (!isNil {CUPZEUS_curatorObjectsUIDMap get (getPlayerUID _unit)}) then
		{
			_curator addCuratorEditableObjects [CUPZEUS_curatorObjectsUIDMap get (getPlayerUID _unit)];
			CUPZEUS_curatorObjectsUIDMap set [getPlayerUID _unit, nil];
		};
	};
	_curator
};

CUPZEUS_denyZeus = 
{
	params ["_unit", ["_displayMessages", CUPZEUS_displayMessages], ["_reason",""]];
	if (_displayMessages > 0) then
	{
		(format ["Zeus denied%1",_reason]) remoteExec ["systemChat", _unit];
	};
};

CUPZEUS_handleRelinquish = 
{
	_unit = _this;
	private ["_curator"];
	_curator = getAssignedCuratorLogic _unit;
	_unit setVariable ["CUPZEUS_curatorObjects", curatorEditableObjects _curator];
	unassignCurator _curator;
	_curator call CUPZEUS_attemptModuleDelete;
	_unit setVariable ["CUPZEUS_isCurator", false];
	switch (CUPZEUS_displayMessages) do
	{
		case 1: {"Zeus relinquished" remoteExec ["systemChat", _unit];};
		case 2: {(format ["%1 relinquished Zeus", name _unit]) remoteExec ["systemChat", 0];};
	};
};

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
	
	_unit remoteExec ["CUPZEUS_handleAdminRequest", _admin];
};

CUPZEUS_handleAdminResponse = 
{
	params ["_unit", "_grant", "_admin"];
	if ((admin owner _admin) > 0) then
	{
		if (_grant) then
		{
			[_unit, nil, " by admin"] call CUPZEUS_grantZeus;
		} else
		{
			[_unit, nil, " by admin"] call CUPZEUS_denyZeus;
		};
	};
};

CUPZEUS_handleRespawnServer = 
{
	params ["_unit", "_corpse"];
	if (_corpse getVariable "CUPZEUS_isCurator") then
	{
		_curator = [_unit] call CUPZEUS_assignCurator;
		_curator addCuratorEditableObjects [(_corpse getVariable "CUPZEUS_curatorObjects")];
	} else
	{
		if (!isNil {_corpse getVariable "CUPZEUS_curatorObjects"}) then
		{
			_unit setVariable ["CUPZEUS_curatorObjects", _corpse getVariable "CUPZEUS_curatorObjects"];
		};
	};
};

CUPZEUS_handleDisconnect = 
{
	params ["_unit", "_id", "_uid", "_name"];
	if !(isNil "CUPZEUS_curatorModuleGroup") then
	{
		if (getAssignedCuratorLogic _unit in units CUPZEUS_curatorModuleGroup) then
		{
			private "_curator";
			_curator = getAssignedCuratorLogic _unit;
			_unit setVariable ["CUPZEUS_curatorObjects", curatorEditableObjects _curator];
			unassignCurator _curator;
			_curator call CUPZEUS_attemptModuleDelete;
		};
	};
	if (!isNil {_unit getVariable "CUPZEUS_curatorObjects"}) then
	{
		CUPZEUS_curatorObjectsUIDMap set [_uid, _unit getVariable "CUPZEUS_curatorObjects"];
	};
};

addMissionEventHandler ["HandleDisconnect", CUPZEUS_handleDisconnect];

CUPZEUS_handleListRequest = 
{
	_unit = _this; 
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

/**
"Deactivates" curator module, by moving it to the inactive group so that it may be reused later
This is because Arma really doesn't like it when you try to delete curator modules. 
**/
CUPZEUS_attemptModuleDelete = 
{
	if !(isNull _this) then
	{
		if (isNil "CUPZEUS_inactiveModuleGroup") then
		{
			CUPZEUS_inactiveModuleGroup = createGroup sideLogic;
			CUPZEUS_inactiveModuleGroup createUnit ["Logic", _this, [], 1, "NONE"]; // create dummy unit to prevent group garbage collection
		};
		_this removeCuratorEditableObjects [curatorEditableObjects _this, true];
		[_this] joinSilent CUPZEUS_inactiveModuleGroup;
	};
};