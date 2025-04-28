--WIP

-- These are just vanilla daemons and can be spawned in.

        -- blowfish2 - Blowfish 2.0
        -- fractal2 - Fractal 2.0
        -- modulate2 - Modulate 2.0
        -- portcullis2 - Portcullis 2.0

-- These are custom daemons that would need to be made, and then can be spawned in.

        -- alert - all guards at the start of the mission are alerted. Tweak Alert daemon from PE.
        -- chiton2 - Guards have permanent +2 armour. Might already exist for Endless?
        -- labyrinth2 - Labyrinth for 20 turns
        -- echo2 - Every turn, a device is rebooted and recaptured [i.e. spawn Echo with 0% reversal chance]. Just take Failsafe (from the Mainframe mission), change devices to 1 per turn and make it permanent. It already can't be reversed IIRC.
        -- paradox2 - Paradox for 10 turns
        -- rubiks2 - All firewalls raised by 2 at the start of the mission when spawned.

-- I would recommend all of these be implemented as daemons as well. (Also, if they're daemons, then they can be used on story missions as long as the interface to spawn them in itself works on story missions.)

        -- lockdown - The exit is locked for 20 turns: Tweak Gatekeeper from PE
        -- nullcameras - Security Cameras cannot be hacked [not strictly necessary, it can be enforced manually]. This exists in Manual Hacking.
        -- pinpoint - Every turn, an agent is located [like a scanning amp]. Easy, just reuse scan amp code i.e. alarm level 5/6 code and tie it to a daemon.
        -- specoops - all non-civilian guards at the start of the mission are Spec Ops. A bit trickier.
        -- validoops - all daemons initially installed on mainframe devices are Validate. Very easy.
local util = include("modules/util")
local abilitydefs = include( "sim/abilitydefs" ) 
-------------------------------------------------------
-- some pseudocode for the spawning
--ref: function simplayer:addMainframeAbility(sim, abilityID, hostUnit, reversalOdds )

local function spawnDaemonOnInput( noDaemonReversal = true,, blah2 )
	--when player inputs string into field:

-- make sure correct daemon is returned regardless of case typoes
	local fixedInput = util.tolower(inputString)
	local daemonID = daemonDict[fixedInput]
	if abilitydefs.lookupAbility(daemonID) then
		sim:getNPC():addMainframeAbility( sim, daemon, nil, 0)
	end
-- we never want these reversed! passing 0 here only sets  base reversal odds to zero and doesn't actually prevent reversal if player has e.g. Brimstone. Would need to add noDaemonReversal = true to the daemons to be extra sure.
end

local daemonDict = {

["blowfish2"] =	"alertBruteForce",
["fractal2"] =	"alertDuplicator", 
["modulate2"] = "alertModulate",
["portcullis2"] = "alertportcullis",
["chiton2"] = "chitonAlarm_2",
["alert"] = "sabotage_alert", --custom/from PE
["labyrinth2"] = "sabotage_labyrinth2", --custom
["echo2"] = "sabotage_echo2", -- custom
["paradox2"] = "sabotage_paradox2", -- custom
["rubiks2"] = "sabotage_rubiks2", -- custom
["lockdown"] = "sabotage_lockdown", -- custom/from PE
["validoops"] = "sabotage_validoops", --custom
["pinpoint"] = "sabotage_pinpoint", --custom
["nullcameras"] = "sabotage_nullcameras", --custom --TBC
["specoops"] = "sabotage_specoops", --custom -- TBC --probably not a daemon?
}
