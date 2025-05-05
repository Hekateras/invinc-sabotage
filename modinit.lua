local util = include("modules/util")
local simdefs = include( "sim/simdefs" )

local custom_loading_screen_tips = {
"Welcome to SABOTAGE MODE!",
"Fun fact: Invisible, Inc. is the best game ever made.",
"Beware the lamp.",
}

local function earlyInit(modApi)
	modApi.requirements = {"Sim Constructor", "Contingency Plan", "Incognita Socket: Online Multiplayer", "Function Library"}
end

local function init( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	
	local abilitydefs = include( "sim/abilitydefs" )
	local simquery = include( "sim/simquery" )
	local simunit = include( "sim/simunit" )
	local serverdefs = include( "modules/serverdefs" )

	-- reusing PE GUI for daemon icons
	KLEIResourceMgr.MountPackage( dataPath .. "/pe_gui_daemons.kwad", "data" )
	KLEIResourceMgr.MountPackage( dataPath .. "/gui_hats.kwad", "data" )
	KLEIResourceMgr.MountPackage( dataPath .. "/anims_hats.kwad", "data" )
	
	modApi:addGenerationOption("sabotage",  "sabotage", "sabotage description", {enabled = true, noUpdate = true} )
	
	local STRINGS = include("strings")
	STRINGS.LOADING_TIPS = custom_loading_screen_tips --replace entirely
	
	-- wrap for nullcameras daemon effect, copied from Manual Hacking mod
	local mainframe = include("sim/mainframe")
	local canBreakIce_old = mainframe.canBreakIce
	mainframe.canBreakIce = function( sim, targetUnit, equippedProgram, ... )
		local result, reason = canBreakIce_old( sim, targetUnit, equippedProgram, ... )
		
		if result and targetUnit:getTraits().mainframe_camera and sim:getTags().nullcameras then -- flag set by daemon
			return false, "CAMERA HACKING BLOCKED"
		end
		
		return result, reason
	end

	--wrap makeAgentConnection to issue the trigger for the hook.
	local mission_util = include("sim/missions/mission_util")
	local makeAgentConnection_old = mission_util.makeAgentConnection
	mission_util.makeAgentConnection = function( script, sim, ... )
		makeAgentConnection_old(script, sim, ...)
		sim:triggerEvent( "finishedAgentConnection" )
	end	

	include( scriptPath .. "/input_daemons" )
end

local function load(modApi, options, params)
	local scriptPath = modApi:getScriptPath()
	local abilitydefs = include( "sim/abilitydefs" )
	local simquery = include( "sim/simquery" )
	local simunit = include( "sim/simunit" )
	local serverdefs = include( "modules/serverdefs" )
	
	if options["sabotage"].enabled then
	
		modApi:addNewUIScreen( "modal-select-daemons", scriptPath.."/modal-select-daemons" )
	
		--local escape_mission = include( scriptPath .. "/escape_mission" )
		--modApi:addEscapeScripts(escape_mission)	
		
		-- for k, v in pairs(include( scriptPath .. "/animdefs" )) do
			-- modApi:addAnimDef( k, v )
		-- end	

		-- for k, v in pairs(include( scriptPath .. "/itemdefs" )) do
			-- modApi:addItemDef( k, v )
		-- end	
		
		-- modApi:addAbilityDef( "ability", scriptPath .."/ability" )
		
		-- local commondefs = include( scriptPath .. "/commondefs")
		-- modApi:addTooltipDef( commondefs )
		
		for k, v in pairs(include( scriptPath .. "/npc_abilities" )) do
			modApi:addDaemonAbility( k, v )
		end		

	end	
	
end

local function lateLoad( modApi, options)
	local scriptPath = modApi:getScriptPath()
	local dataPath = modApi:getDataPath()
	local commondefs = include( "sim/unitdefs/commondefs" )
	local AGENT_ANIMS = commondefs.AGENT_ANIMS
	local GUARD_ANIMS = commondefs.GUARD_ANIMS	
		
	local anims = include("animdefs")
	for k,v in pairs(anims.defs) do
		if v.animMap and (v.animMap == GUARD_ANIMS) then
			if v.build and (type(v.build) == "table") then	
				table.insert(v.build,"data/anims/characters/hats/party_hat.abld" )
			end
			
			if v.grp_build and (type(v.grp_build) == "table") then	
				table.insert(v.grp_build,"data/anims/characters/hats/grp_party_hat.abld" )
			end
		end
	end						
end

local function initStrings(modApi)
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	local MOD_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "SABOTAGE", MOD_STRINGS)
end

-- local function lateLoad(modApi, options, params, allOptions)
-- end

-- local function unload()
-- end

return {
	earlyInit = earlyInit,
	init = init,
	load = load,
	lateLoad = lateLoad,
	-- unload = unload,
	initStrings = initStrings,
}
