# Dead Simple Dynamic Zeus Request System

Allows a select list of players to take and/or relinquish Zeus powers via simple actions. 

Features:
- Dead Simple setup
- Minimal interface through actions only
- Allowed curators can be defined by selected units or by player IDs

Planned:
- Respawn handler
- Disconnect handler

## Installation

Add it to your mission by copying the "cupzeus" folder. In your `initServer.sqf`, add the following line:-

`call compile preprocessfilelinenumbers "cupzeus\cupzeus_server.sqf";`

In your `initPlayerLocal.sqf`, add the following:-

`call compile preprocessfilelinenumbers "cupzeus\cupzeus_client.sqf";`

At the top of `cupzeus_server.sqf`, there are a couple of parameters you can change. 

## Defining Allowed Curators

The allowed curators list is defined on the server side, in an array named `CUPZEUS_curatorList`. 

It accepts 3 types. 

Firstly, unit variable names (i.e. the name defined in the editor). This is not recommended for most missions, as it can break if one of the units is not present (e.g. not selected by any players or AI). Example: 

`CUPZEUS_curatorList = [bob1, bob2, jeff];`

Alternatively, you can use the same variables, but pass them as strings instead. This is the recommended method, as it won't break anything when a unit is missing. Example: 

`CUPZEUS_curatorList = ["bob3", "bob4", "geoff"];`

Finally, you can use player UIDs. This is the more secure way, as it will allow only that specific player to access the curator, however it is also the more restrictive for the same reason. Example: 

`CUPZEUS_curatorList = [12345678901234567890, 98765432109876543210];`

You can mix-and-match all 3 types. 

## Adding Request Action

Adding a request action to any object is a simple matter of calling the following on the client-side:

`[object, requestText, relinquishText] call CUPZEUS_addRequestAction;`

`object` is required; it is the object to which the actions will be attached. 

`requestText` and `relinquishText` are both optional; they define the text that will be displayed for the actions. By default, they are set to simple `"Request Zeus"` and `"Relinquish Zeus"`, respectively. 

