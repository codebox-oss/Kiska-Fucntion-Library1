/* ----------------------------------------------------------------------------
Function: KISKA_fnc_GCHOnLoad_closeButton

Description:
	Adds control event handler to the close buttont that will close the dialog.

Parameters:
	0: _control <CONTROL> - The control for the close button

Returns:
	NOTHING

Examples:
    (begin example)
        [_control] call KISKA_fnc_GCHOnLoad_closeButton;
    (end)

Author:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
#define SCRIPT_NAME "KISKA_fnc_GCHOnLoad_canBeDeletedCombo"
scriptName SCRIPT_NAME;

params ["_control"];

(uiNamespace getVariable "KISKA_GCH_display") closeDisplay 2;