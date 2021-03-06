/* ----------------------------------------------------------------------------
Function: KISKA_fnc_addRespawnEventHandlers

Description:
	Adds the respawn eventHandlers for KISKA's rally point system.
	
	Initialized by KISKA_fnc_initializeRespawnSystem.

Parameters:
	NONE

Returns:
	NOTHING

Examples:
    (begin example)
		
    (end)

Author:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */

if !(isMultiplayer OR {!hasInterface}) exitWith {};

private _player = call KISKA_fnc_getPlayerObject;

if (isNull _player) exitWith {};


_player addEventHandler ["Killed", {
	params ["_corpse"];

	KISKA_playerGroup = group _corpse;
	
	if (!isNil "KISKA_spawnId") then {
		_corpse removeAction KISKA_spawnId;
		
		KISKA_spawnId = nil;
	};
}];


_player addEventHandler ["Respawn", {
	params ["_unit"];
	
	if (!isNull KISKA_playerGroup AND (!((group _unit) isEqualTo KISKA_playerGroup))) then {
		[_unit] joinSilent KISKA_playerGroup;
	};
	
	if (!isNil "KISKA_spawnInfo") then {
		private _spawnInfo = KISKA_spawnInfo;
		KISKA_spawnInfo = nil;

		_spawnInfo spawn KISKA_fnc_updateRallyAction;
	};

}];