#include "Headers\Command Menu Macros.hpp"
#include "Headers\Support Type IDs.hpp"
/* ----------------------------------------------------------------------------
Function: KISKA_fnc_callingForArsenalSupplyDrop

Description:
	Used as a means of expanding on the "expression" property of the CfgCommunicationMenu.
	
	This is essentially just another level of abrstraction to be able to more easily reuse
	 code between similar supports and make things easier to read instead of fitting it all
	 in the config.

Parameters:
	0: _supportClass <STRING> - The class as defined in the CfgCommunicationMenu
	1: _commMenuArgs <ARRAY> - The arguements passed by the CfgCommunicationMenu entry
		0: _caller <OBJECT> - The player calling for support
		1: _targetPosition <ARRAY> - The position (AGLS) at which the call is being made 
			(where the player is looking or if in the map, the position where their cursor is)
		2: _target <OBJECT> - The cursorTarget object of the player
		3: _is3d <BOOL> - False if in map, true if not
		4: _commMenuId <NUMBER> - The ID number of the Comm Menu added by BIS_fnc_addCommMenuItem
		5: _supportType <NUMBER> - The Support Type ID
	2: _count <NUMBER> - Used for keeping track of how many of a count a support has left (such as rounds)
	3: _type <NUMBER> - Determines if either Attack Helicopter CAS or Transport gunners

Returns:
	NOTHING

Examples:
    (begin example)
		[] call KISKA_fnc_callingForArsenalSupplyDrop;
    (end)

Authors:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_callingForArsenalSupplyDrop";

#define FLYIN_RADIUS 2000
#define ARSENAL_LIFETIME -1

params [
	"_supportClass",
	"_commMenuArgs",
	["_useCount",-1]
];


private _supportConfig = [["CfgCommunicationMenu",_supportClass]] call KISKA_fnc_findConfigAny;
if (isNull _supportConfig) exitWith {
	[["Could not find class: ",_supportClass," in any config!"],true] call KISKA_fnc_log;
	nil
};


private _menuPathArray = [];
private _menuVariables = []; // keeps track of global variable names to set to nil when done

// get use count from config if -1
if (_useCount < 0) then {
	_useCount = getNumber(_supportConfig >> "useCount");
	_this set [2,_useCount];
};

/* ----------------------------------------------------------------------------
	Vehicle Select Menu
---------------------------------------------------------------------------- */
private _vehicles = [_supportConfig >> "vehicleTypes"] call BIS_fnc_getCfgDataArray;
if (_vehicles isEqualTo []) then {
	_vehicles = [side (_commMenuArgs select 0),_commMenuArgs select 5] call KISKA_fnc_getSupportVehicleClasses;
};

private _vehicleMenu = [_vehicles] call KISKA_fnc_createVehicleSelectMenu;
SAVE_AND_PUSH(VEHICLE_SELECT_MENU_STR,_vehicleMenu)


/* ----------------------------------------------------------------------------
	Bearings Menu
---------------------------------------------------------------------------- */
_bearingsMenu = BEARING_MENU;

SAVE_AND_PUSH(BEARING_MENU_STR,_bearingsMenu)


/* ----------------------------------------------------------------------------
	flyInHeight Menu
---------------------------------------------------------------------------- */
private _flyInHeights = [_supportConfig >> "flyinHeights"] call BIS_fnc_getCfgDataArray;
private _flyInHeightMenu = [
	["Altitude",false]
];
{
	_flyInHeightMenu pushBackUnique DISTANCE_LINE(_x,0);
} forEach _flyInHeights;
SAVE_AND_PUSH(FLYIN_HEIGHT_MENU_STR,_flyInHeightMenu)




/* ----------------------------------------------------------------------------
	Create Menu Path
---------------------------------------------------------------------------- */
private _args = _this; // just for readability
_args pushBack _menuVariables;

[
	_menuPathArray,
	{
		params ["_vehicleClass","_approachBearing","_flyinHeight"];

		private _commMenuArgs = _args select 1;
		private _dropPosition = _commMenuArgs select 1;
		
		[
			_dropPosition,
			_vehicleClass,
			_flyinHeight,
			_approachBearing,
			FLYIN_RADIUS,
			ARSENAL_LIFETIME,
			side (_commMenuArgs select 0)
		] call KISKA_fnc_arsenalSupplyDrop;
		
		[SUPPORT_TYPE_ARSENAL_DROP] call KISKA_fnc_supportNotification;

		// if support still has uses left
		private _useCount = _args select 2;
		if (_useCount > 1) then {
			_useCount = _useCount - 1;
			ADD_SUPPORT_BACK(_useCount)
		};

		UNLOAD_GLOBALS
	},
	_args,
	{
		ADD_SUPPORT_BACK(_args select 2)
		UNLOAD_GLOBALS
	}
] spawn KISKA_fnc_commandMenuTree;


nil