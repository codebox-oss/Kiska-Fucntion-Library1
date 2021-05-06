/* ----------------------------------------------------------------------------
Function: KISKA_fnc_getVariableTarget

Description:
	Gets a variable from a remote target object, id, group, or string (uses remoteExec targets)

	Takes a bit of time and therefore needs to be scheduled.

Parameters:
	0: _variableName : <STRING> - The string name of the varaible to get
	1: _namespace : <NAMESPACE, OBJECT, STRING, GROUP, CONTROL, or LOCATION> - The namespace to get the variable from
	2: _defaultValue : <ANY> - If the variable does not exist for the target, what should be returned instead
	3: _target : <NUMBER, OBJECT, GROUP, or STRING> - Where the _target is local will be where the variable is taken from

Returns:
	<ANY> - Whatever the variable is

Examples:
    (begin example)
		null = [] spawn {
			// need to call for direct return
			_serversSomeVariable = ["someVariable",missionNamespace,"",2] call KISKA_fnc_getVariableTarget;
		};
    (end)

Author(s):
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
#define SCRIPT_NAME "KISKA_fnc_getVariableTarget"
scriptName SCRIPT_NAME;

if (!canSuspend) exitWith {
	[SCRIPT_NAME,"Must be run in scheduled environment",false,true,true] call KISKA_fnc_log;
	-1
};

params [
	["_variableName","",[""]],
	["_namespace",missionNamespace,[missionNamespace,objNull,grpNull,"",controlNull,locationNull]],
	["_defaultValue",-1],
	["_target",2,[123,objNull,grpNull,""]]
];

if (_variableName isEqualTo "") exitWith {
	[SCRIPT_NAME,"_variableName is empty",false,true,true] call KISKA_fnc_log;
	-1
};


// create a unique variable ID for network tranfer
private _messageNumber = missionNamespace getVariable ["KISKA_getVarTargetQueue_count",0];
_messageNumber = _messageNumber + 1;
private _saveVariable = ["KISKA_GVT",clientOwner,"_",_messageNumber] joinString "";


[_namespace,_variableName,_saveVariable,_defaultValue,clientOwner] remoteExecCall ["KISKA_fnc_getVariableTarget_sendBack",_target];

waitUntil {
	if (!isNil {missionNamespace getVariable _saveVariable}) exitWith {
		[SCRIPT_NAME,["Got variable",_saveVariable,"from target",_target],true,false,true] call KISKA_fnc_log;
		true
	};
	sleep 0.25;
	[SCRIPT_NAME,["Waiting for variable from target:",_target],true,false,true] call KISKA_fnc_log;
	false
};

private _return = missionNamespace getVariable _saveVariable;
missionNamespace setVariable [_saveVariable,nil]; 


_return