/* ----------------------------------------------------------------------------
Function: KISKA_fnc_arsenalSupplyDrop

Description:
	Spawns in an aircraft that flies over a DZ to drop off an arsenal.

Parameters:
	0: _dropPosition : <ARRAY> - The position (area) to drop the arsenal
  	1: _vehicleClass : <STRING> - The class of the vehicle to drop the arsenal
	2: _dropAlt : <NUMBER> - The flyInHeight of the drop vehicle
	3: _flyDirection : <NUMBER> - The compass bearing for the aircraft to apporach from (if < 0, it's random)
	4: _flyInRadius : <NUMBER> - How far out the drop vehicle will spawn and then fly in
	5: _lifeTime : <NUMBER> - How long until the arsenal is deleted
	6: _side : <SIDE> - The side of the drop vehicle

Returns:
	NOTHING

Examples:
    (begin example)
		[position player] call KISKA_fnc_arsenalSupplyDrop;
    (end)

Author(s):
	Hilltop(Willtop) & omNomios,
	Modified by: Ansible2 // Cipher
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_arsenalSupplyDrop";

params [
	"_dropPosition",
	["_vehicleClass","B_T_VTOL_01_vehicle_F",[""]],
	["_dropAlt",200,[123]],
	["_flyDirection",-1,[123]],
	["_flyInRadius",2000,[123]],
	["_lifeTime",600,[123]],
	["_side",BLUFOR,[sideUnknown]]
];

// get directions for vehicle to fly 
if (_flyDirection < 0) then {
	_flyDirection = round (random 360);
};
private _flyFromDirection = [_flyDirection + 180] call CBA_fnc_simplifyAngle;
private _spawnPosition = _dropPosition getPos [_flyInRadius,_flyFromDirection];
_spawnPosition set [2,_dropAlt];

private _relativeDirection = _spawnPosition getDir _dropPosition;

// spawn vehicle
private _vehicleArray = [_spawnPosition,_relativeDirection,_vehicleClass,_side] call KISKA_fnc_spawnVehicle;

private _aircraftCrew = _vehicleArray select 1;
_aircraftCrew apply {
	_x setCaptive true;
};

private _aircraftGroup = _vehicleArray select 2;
_aircraft flyInHeight _dropAlt;

private _aircraft = _vehicleArray select 0;
_airCraft move _dropPosition;

// give it a waypoint and delete it after it gets there
private _flyToPosition = _dropPosition getPos [_flyInRadius,_relativeDirection];

[_aircraft,_dropPosition,_aircraftGroup,_flyToPosition,_lifeTime] spawn {
	params ["_aircraft","_dropPosition","_aircraftGroup","_flyToPosition","_lifeTime"];
	waitUntil {
		if (_aircraft distance2D _dropPosition < 40) exitWith {true};
		sleep 0.25;
		false
	};

	// go to deletion point
	[
		_aircraftGroup,
		_flyToPosition,
		-1,
		"MOVE",
		"SAFE",
		"BLUE",
		"NORMAL",
		"NO CHANGE",
		"
			private _aircraft = objectParent this;
			thisList apply {
				_aircraft deleteVehicleCrew _x;
			};
			deleteVehicle _aircraft;
		",
		[0,0,0],
		50
	] call CBA_fnc_addWaypoint;


	sleep 0.1;
	
	private _aircraftAlt = (getPosATL _aircraft) select 2;
	private _boxSpawnPosition = _aircraft getRelPos [15,180];
	private _arsenalBox = ([["B_supplyCrate_F"],_aircraftAlt,_boxSpawnPosition] call KISKA_fnc_supplyDrop) select 0;
	clearMagazineCargoGlobal _arsenalBox;
	clearWeaponCargoGlobal _arsenalBox;
	clearBackpackCargoGlobal _arsenalBox;
	clearItemCargoGlobal _arsenalBox;
	
	// make sure it's on the ground before we start the countdown to deletetion
	waitUntil {
		if (((getPosATL _arsenalBox) select 2) < 2) exitWith {true};
		sleep 5;
		false
	};
	
	sleep _lifeTime;
	
	deleteVehicle _arsenalBox;
};


nil