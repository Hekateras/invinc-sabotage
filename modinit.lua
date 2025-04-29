local util = include("modules/util")
local simdefs = include( "sim/simdefs" )

local custom_loading_screen_tips = {
"Welcome to SABOTAGE MODE!",
}

local function init( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	
	modApi.requirements = {"Sim Constructor", "Contingency Plan",}
		
	local abilitydefs = include( "sim/abilitydefs" )
	local simquery = include( "sim/simquery" )
	local simunit = include( "sim/simunit" )
	local serverdefs = include( "modules/serverdefs" )

	-- reusing PE GUI for daemon icons
	KLEIResourceMgr.MountPackage( dataPath .. "/programs_extended_gui.kwad", "data" )
	KLEIResourceMgr.MountPackage( dataPath .. "/programs_extended_gui2.kwad", "data" )
	--KLEIResourceMgr.MountPackage( dataPath .. "/anims.kwad", "data" ) 
	
	modApi:addGenerationOption("sabotage",  "sabotage", "sabotage description", {enabled = true, noUpdate = true} )
	
	local STRINGS = include("strings")
	STRINGS.LOADING_TIPS = custom_loading_screen_tips --replace entirely
	
	-- wrap for nullcameras daemon effect, copied from Manual Hacking mod
	local mainframe = include("sim/mainframe")
	local canBreakIce_old = mainframe.canBreakIce
	mainframe.canBreakIce = function( sim, targetUnit, equippedProgram, ... )
		local result, reason = canBreakIce_old( sim, targetUnit, equippedProgram, ... )
		if equippedProgram == nil then
			equippedProgram = player:getEquippedProgram()
		end
		if equippedProgram == nil then 
			return false, STRINGS.UI.REASON.NO_PROGRAM
		end 
		local player = sim:getCurrentPlayer()
		if equippedProgram and player and targetUnit and targetUnit:isValid() and (targetUnit:getTraits().mainframe_status == "active") and sim:getTags().nullcameras then -- flag set by daemon
			if  targetUnit:getTraits().mainframe_camera then
				return false, "CAMERA HACKING BLOCKED"
			end
		end
		return result, reason
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

local function initStrings(modApi)
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()
	local MOD_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "SABOTAGE", MOD_STRINGS)
	
	modApi.requirements = {"Incognita Socket: Online Multiplayer"}
end

-- local function lateLoad(modApi, options, params, allOptions)
-- end

-- local function unload()
-- end

return {
	init = init,
	load = load,
	-- unload = unload,
	initStrings = initStrings,
}
