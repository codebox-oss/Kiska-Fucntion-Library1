/* ----------------------------------------------------------------------------
Function: KISKA_fnc_reassignCurator

Description:
	Reassigns a curator object to a unit.

Parameters:
	0: _isManual : <BOOL> - Was this called from the diary entry (keeps hints from showing otherwise)
	1: _curatorObject : <OBJECT or STRING> - The curator object to reassign

Returns:
	NOTHING

Examples:
    (begin example)
		// show hint messages
		[true] call KISKA_fnc_reassignCurator;

    (end)

Author(s):
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_reassignCurator";

params [
	["_isManual",false,[true]],
	["_curatorObject",objNull,[objNull,""]]
];

// check if player is host or admin
if (!(call BIS_fnc_admin > 0) AND {clientOwner != 2}) exitWith {
	if (_isManual) then {
		hint "Only admins can be assigned curator";
	};
};

if (_curatorObject isEqualType "") then {
	_curatorObject = missionNamespace getVariable [_curatorObject,objNull];
};

if (isNull _curatorObject) exitWith {
	"_curatorObject isNull!" call BIS_fnc_error;
};

private _unitWithCurator = getAssignedCuratorUnit _curatorObject;
if (isNull _unitWithCurator) then {
	null = [player,_curatorObject] remoteExecCall ["assignCurator",2];
} else {
	if (alive _unitWithCurator) then {
		// no sense in alerting player if they are the curator still
		if (!(_unitWithCurator isEqualTo player)) then {
			hint "Another currently alive admin has the curator assigned to them already";
		} else {
			hint "You are already the curator";
		};
	} else {
		null = [_unitWithCurator,_isManual,_curatorObject] spawn {
			params ["_unitWithCurator","_isManual","_curatorObject"];
			null = [_curatorObject] remoteExec ["unAssignCurator",2];
			
			// wait till curator doesn't have a unit to give it the player
			waitUntil {
				if !(isNull (getAssignedCuratorUnit _curatorObject)) exitWith {
					null = [player,_curatorObject] remoteExecCall ["assignCurator",2];
					if (_isManual) then {
						hint "You are now the curator";
					};
					true
				};
				
				null = [_curatorObject] remoteExec ["unAssignCurator",2];
				
				sleep 2;
				false
			};
		};
	};
};