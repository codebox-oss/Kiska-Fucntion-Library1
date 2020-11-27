/* ----------------------------------------------------------------------------
Function: KISKA_fnc_playMusic

Description:
	Plays music with smooth fade between tracks. Must be run in scheduled environment (spawn)

Parameters:

	0: _track <STRING> - Music to play
	1: _startTime <NUMBER> - Starting time of music. -1 for random start time
	2: _canInterrupt <BOOL> - Interrupt playing music
	3: _volume <NUMBER> - Volume to play at
	4: _fadeTime <NUMBER> - Time to fade tracks down & up

Returns:
	NOTHING

Examples:
    (begin example)

		null = ["track", 0, true, 1, 3] spawn KISKA_fnc_playMusic;

    (end)

Author:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */

if !(hasInterface) exitWith {};

if !(canSuspend) exitWith {
	"fadeMusic does not work in unscheduled environment" call BIS_fnc_error;
};

params [
	["_track","",[""]],
	["_startTime",0,[123]],
	["_canInterrupt",true,[true]],
	["_volume",1,[1]],
	["_fadeTime",3,[1]]
];

if (!(isCLass (configFile / "cfgMusic" / _track)) AND {!(isClass (missionConfigFile / "cfgMusic" / _track))}) exitWith {
	"_track is undefined in music config" call BIS_fnc_error;
};

private _musicPlaying = call KISKA_fnc_isMusicPlaying;
if (_musicPlaying AND {!_canInterrupt}) exitWith {};

if (_musicPlaying) then {
	_fadeTime fadeMusic 0;
} else {
	_fadeTime = 0;
};

if (_startTime < 0) then {
	private _duration = getNumber (configFile >> "cfgMusic" >> _track >> "duration"); // will return 0 if undefined
	
	if (isNil "_duration") then {
		_duration = getNumber (missionConfigFile >> "cfgMusic" >> _track >> "duration");
	};

	_startTIme = round (random [0, _duration / 2, _duration]);
};

sleep (_fadeTime + 0.1);

playMusic [_track,_startTime];
	
0 fadeMusic 0;
		
_fadeTime fadeMusic _volume;