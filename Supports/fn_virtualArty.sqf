/* ----------------------------------------------------------------------------
Function: KISKA_fnc_virtualArty

Description:
	Calls for an artillery or mortar strike at a designated position and marks the spot.

Parameters:
	0: _target <OBJECT, ARRAY, or STRING(marker)> - The target you want to cluter fire around
	1: _ammoType <STRING> - The ammo type from cfgAmmo 
	2: _radius <NUMER> - Spread of rounds
	3: _numberOfRounds <NUMER> - The number of rounds to fire
	4: _delayBetween <NUMER> - Time between shots
	5: _markPosition <BOOL> - Marks the target position with smoke and chemlight (delete after 20 seconds)

Returns:
	NOTHING

Examples:
    (begin example)
		[target_1,"Sh_155mm_AMOS"] spawn KISKA_fnc_virtualArty;
    (end)

Authors:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_virtualArty";

if (!canSuspend) exitWith {
	["Needs to be run in scheduled; Exiting to scheduled...",true] call KISKA_fnc_log;
	_this spawn KISKA_fnc_virtualArty;
};

params [
	["_fireAtPosition",objNull,[[],objNull],""],
	["_ammoType","Sh_155mm_AMOS",[""]],
	["_radius",25,[123]],
	["_numberOfRounds",3,[123]],
	["_delayBetween",5,[123]],
	["_markPosition",false,[true]]
];

// flare round need to fall slower
if (_ammoType == "Flare_82mm_AMOS_White") exitWith {
	[_fireAtPosition,_ammoType,15,1,1,{},nil,250,1] spawn BIS_fnc_fireSupportVirtual;
};

if (_markPosition) then {
	[_fireAtPosition] spawn {
		params ["_fireAtPosition"];		
		private _chemlight = createvehicle ["Chemlight_green_infinite",_fireAtPosition,[],0,"NONE"];
		private _smoke = createvehicle ["G_40mm_SmokeRed_infinite",_fireAtPosition,[],0,"NONE"];
		//private _flare = createvehicle ["F_40mm_Red",_fireAtPosition,[],0,"NONE"];
		sleep 20;
		deleteVehicle _chemlight;
		deleteVehicle _smoke;
		//deleteVehicle _flare;
	};
};

// some delay for "sim" purposes
sleep 5;

[_fireAtPosition,_ammoType,_radius,_numberOfRounds,_delayBetween,{},nil,1300] spawn BIS_fnc_fireSupportVirtual;