/* ----------------------------------------------------------------------------
Function: KISKA_fnc_playSound3D

Description:
	Plays a sound 3D but the function accepts the sound name rather then just the file path.

Parameters:
	0: _sound <STRING> - The sound to play. Sound classname like the command playSound
	1: _origin <OBJECT or ARRAY> - The position (ASL) or object from which the sound comes from
	2: _distance <NUMBER> - Distance at which the sound can be heard
	3: _volume <NUMBER> - Range from 0-5
	4: _isInside <BOOL> - Is _origin inside
	5: _pitch <NUMBER> - Range from 0-5


Returns:
	BOOL

Examples:
    (begin example)

		["BattlefieldJet1_3D",(getPosASL player) vectorAdd [50,50,100],200] call KISKA_fnc_playSound3D;

    (end)

Author(s):
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
params [
	["_sound","",[""]],
	["_origin",objNull,[objNull,[]]],
	["_distance",20,[123]],
	["_volume",1,[123]],
	["_isInside",false,[true]],
	["_pitch",1,[123]]
];


// verify params
if (_sound isEqualTo "") exitWith {
	"_sound is empty string" call BIS_fnc_error;
	false
};

if (!(isCLass (configFile / "CfgSounds" / _sound)) AND {!(isClass (missionConfigFile / "CfgSounds" / _sound))}) exitWith {
	"_sound is undefined in config" call BIS_fnc_error;
	false
};

if ((_origin isEqualType objNull) AND {isNull _origin}) exitWith {
	"_origin object isNull" call BIS_fnc_error;
	false
};

if ((_origin isEqualType []) AND {_origin isEqualTo []}) exitWith {
	"_origin is empty array" call BIS_fnc_error;
	false
};

if (_distance < 0) exitWith {
	"_distance is negative" call BIS_fnc_error;
	false
};


// get actual path of file form config
private _soundPath = (getArray (configFile >> "CfgSounds" >> _sound >> "sound")) select 0;

if (isNil "_soundPath") then {
	_soundPath = (getArray (missionConfigFile >> "CfgSounds" >> _sound >> "sound")) select 0;
};

if !(_soundPath isEqualType "") exitWith {
	"_sound is configed incorrectly" call BIS_fnc_error;
	false
};


if (_origin isEqualType objNull) then {
	_origin = getPosASL _origin;
};

// check for bohemia weird chars on file paths
private _firstChar = _soundPath select [0,1];
if (_firstChar in ["@","\"]) then {
	_soundPath = [_soundPath,_firstChar] call CBA_fnc_leftTrim;
};

// check if bohemia didn't add file extension
if !(toLower (_soundPath select [(count _soundPath) - 4,4]) in [".wss",".ogg",".wav"]) then {
	private _soundpath1 = _soundPath + ".wss";
	private _soundpath2 = _soundPath + ".ogg";
	private _soundpath3 = _soundPath + ".wav"; // one of these has to be right, right?

	// playsound
	[_soundPath1,_soundPath2,_soundPath3] apply {
		playSound3D [_x,objNull,_isInside,_origin,_volume,_pitch,_distance];
	};
} else {
	// playsound
	playSound3D [_soundPath,objNull,_isInside,_origin,_volume,_pitch,_distance];
};

true