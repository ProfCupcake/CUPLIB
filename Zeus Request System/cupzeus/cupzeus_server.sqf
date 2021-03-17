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
	if ((_client == 2) or
		{(admin _client) > 0} or
		{_unit in CUPZEUS_curatorList} or
		{_unitStr in CUPZEUS_curatorList} or
		{_uid in CUPZEUS_curatorList}) then
	{
		_unit call CUPZEUS_grantZeus;
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
				_unit call CUPZEUS_denyZeus;
			};
		} else
		{
			_unit call CUPZEUS_denyZeus;
		};
	};
};

CUPZEUS_grantZeus = 
{
	private ["_curator", "_respawnEH", "_disconnectEH"];
	if (isNil "CUPZEUS_curatorModuleGroup") then {CUPZEUS_curatorModuleGroup = createGroup sideLogic;};
	_curator = CUPZEUS_curatorModuleGroup createUnit ["ModuleCurator_F", _this, [], 1, "NONE"];
	_curator setVariable ["Addons", 3, true];
	_this assignCurator _curator;
	switch (CUPZEUS_displayMessages) do
	{
		case 1: {"Zeus granted" remoteExec ["systemChat", _this];};
		case 2: {(format ["Zeus granted to %1", name _this]) remoteExec ["systemChat", 0];};
	};
	CUPZEUS_clientRespawnEH = true;
	(owner _this) publicVariableClient "CUPZEUS_clientRespawnEH";
};

CUPZEUS_denyZeus = 
{
	if (CUPZEUS_displayMessages > 0) then
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
	deleteVehicle _curator;
	switch (CUPZEUS_displayMessages) do
	{
		case 1: {"Zeus relinquished" remoteExec ["systemChat", _unit];};
		case 2: {(format ["%1 relinquished Zeus", name _unit]) remoteExec ["systemChat", 0];};
	};
	CUPZEUS_clientRespawnEH = false;
	(owner _unit) publicVariableClient "CUPZEUS_clientRespawnEH";
};

"CUPZEUS_relinquishZeus" addPublicVariableEventHandler CUPZEUS_handleRelinquish;

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
	_response params ["_unit", "_grant"];
	// TODO: add checks to ensure responding admin is still admin, auto-deny if not
	if (_grant) then
	{
		"Admin granted request" remoteExec ["systemChat", _unit];
		_unit call CUPZEUS_grantZeus;
	} else
	{
		"Admin denied request" remoteExec ["systemChat", _unit];
		_unit call CUPZEUS_denyZeus;
	};
};

"CUPZEUS_adminResponse" addPublicVariableEventHandler CUPZEUS_handleAdminResponse;

CUPZEUS_handleRespawnServer = 
{
	params ["", "_params"];
	_params params ["_unit", "_corpse"];
	private "_curator";
	_curator = getAssignedCuratorLogic _corpse;
	unassignCurator _curator; 
	_unit assignCurator _curator;
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
			deleteVehicle _curator;
		};
	};
};

addMissionEventHandler ["HandleDisconnect", CUPZEUS_handleDisconnect];

CUPZEUS_handleListRequest = 
{
	params ["", "_unit"];
	if ((isNil "CUPZEUS_curatorModuleGroup") or {(count (units CUPZEUS_curatorModuleGroup)) == 0}) exitWith
	{
		"No active Zeus operators" remoteExec ["systemChat", _unit];
	};
	"Active Zeus operators:" remoteExec ["systemChat", _unit];
	{
		(format ["%1", (name (getAssignedCuratorUnit _x))]) remoteExec ["systemChat", _unit];
	} forEach (units CUPZEUS_curatorModuleGroup);
};

"CUPZEUS_requestList" addPublicVariableEventHandler CUPZEUS_handleListRequest;