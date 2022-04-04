/* ----------------------------------------------------------------------------
Function: KISKA_fnc_updateRespawnMarkerQuery

Description:
	Acts as a go between for use inside of a string in a diary entry expression.
	(You can't use remoteExecCall with a string inside of double strings)

Parameters:
	NONE

Returns:
	NOTHING

Examples:
    (begin example)
		call KISKA_fnc_updateRespawnMarkerQuery;
    (end)

Author:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
#define KISKA_DIARY "KISKA Systems"
#define SCRIPT_NAME "KISKA_fnc_updateRespawnMarkerQuery"
scriptName SCRIPT_NAME;

if !(hasInterface) exitWith {};

private _group = group player;
if (isNull _group) exitWith {
	["_group was found to be null",true] call KISKA_fnc_log;
};

private _groupLeader = leader _group;
if !(_groupLeader isEqualTo player) exitWith {
	private _string = ["You are not the leader of the group. ",name _groupLeader," is your group leader."] joinString "";
	hint _string;
};

private _groupName = groupId _group;
null = [_groupLeader, ([_groupName,"spawnMarker"] joinString "_"), ([_groupName,"Respawn Beacon"] joinString " ")] remoteExecCall ["KISKA_fnc_updateRespawnMarker",2];