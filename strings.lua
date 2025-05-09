local SABOTAGE_STRINGS = {
	DAEMONS = {
		ALERT =
		{
			NAME = "ALERT",
			DESC = "All guards become alerted. Enjoy!",
			SHORT_DESC = "FACILITY ALERT",
			ACTIVE_DESC = "ALL GUARDS BECOME ALERTED",
		},
		
		ECHO2 =
		{
			NAME = "Echo v2.0",
			DESC = "Reboots a device every turn",
			SHORT_DESC = "REBOOT PROTOCOL",
			ACTIVE_DESC = "1 DEVICE REBOOTED EACH TURN",
		},
		
		RUBIKS2 = 
		{
			NAME = "RUBIKS v2.0",
			DESC = "Raises FIREWALLS",
			SHORT_DESC = "Raises FIREWALLS by two",
			ACTIVE_DESC = "ALL FIREWALLS RAISED BY DAEMON",
		},		

		GATEKEEPER2 =
		{
			NAME = "LOCKDOWN",
			DESC = "Exit elevator is closed for the duration of this Daemon.",
			SHORT_DESC = "EXIT LOCK",
			ACTIVE_DESC = "EXIT ELEVATOR IS LOCKED FOR {1} {1:TURN|TURNS}",
		},
		
		VALIDOOPS = 
		{
			NAME = "VALIDOOPS",
			DESC = "All initial daemons have been set to Validate.",
			SHORT_DESC = "VALIDATION",
			ACTIVE_DESC = "ALL CURRENT DAEMONS ARE NOW VALIDATE",
		},

		SPECOOPS = 
		{
			NAME = "SPECOOPS",
			DESC = "All initial non-civilian guards are replaced by Spec Ops.",
			SHORT_DESC = "GUARDS ARE SPEC OPS",
			ACTIVE_DESC = "STARTING GUARDS ARE NOW SPEC OPS",
		},

		PINPOINT = 
		{
			NAME = "PINPOINT",
			DESC = "A random agent is located each turn.",
			SHORT_DESC = "AGENT PINPOINT",
			ACTIVE_DESC = "ONE AGENT LOCATED EACH TURN",
		},
		
		NULLCAMERAS = 
		{
			NAME = "ENIGMA",
			DESC = "Cameras cannot be hacked through the mainframe.",
			SHORT_DESC = "CAMERAS UNHACKABLE",
			ACTIVE_DESC = "MAINFRAME CAMERA HACKING BLOCKED",
		},
		
		BRIGHTER = 
		{
			NAME = "ILLUMINATE",
			DESC = "The cover in certain rooms is replaced with K&O Lamps.",
			SHORT_DESC = "LAMPED.",
			ACTIVE_DESC = "LAMPS INSTEAD OF COVER.",
		},		
	},	
}

return SABOTAGE_STRINGS
