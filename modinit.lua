local util = include("modules/util")
local simdefs = include( "sim/simdefs" )
local array = include( "modules/array" )

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
	
	--BRIGHTER
	-- replace decor with lamps if daemon is active, but only in entry+objective rooms
	local simengine = include("sim/engine")
	local oldInit = simengine.init
	
	function simengine.init( self, params, levelData, ... )
		self._levelOutput = levelData:parseBoard( params.seed, params )
		
		local cover_cells = {}
		local changed_cells = {}
		
		-- collect all cells which provide both impass and cover (impass check precludes cells with guards on them)
		for i, entry in pairs(self._levelOutput.map) do
			if type(entry) == "table" then
				for i, subentry in pairs(entry) do
					if subentry.cover and subentry.impass and (subentry.impass > 0) and subentry.x and subentry.y and (subentry.procgenRoom.tags["entry"] or subentry.procgenRoom.tags["objective"]) then
						local cover_cell = {subentry.x, subentry.y}
						table.insert(cover_cells,cover_cell)
						-- subentry.cover = nil
					end
				end
			end
		end
		
		-- remove cells that provide cover because there's a non-decor unit on them. prior check for impass we won't have sampled cells with guards
		for k, unit in pairs(self._levelOutput.units) do
			if unit.x and unit.y and unit.template and not (unit.template == "security_camera_1x1")  then
				for i = #cover_cells, 1, -1 do
					local cell = cover_cells[i]
					if (cell[1] == unit.x) and (cell[2] == unit.y) then
						table.remove(cover_cells, i)
					end
				end
			end
		end		
		
		if params.agency.sabotageDaemons and array.find( params.agency.sabotageDaemons, "sabotage_brighter" ) then
		-- Issue: For an e.g. 2x3 decor item on the map, only one of those tiles is assigned the decor kanim. To fix this and prevent empty tiles:
		-- go through cover_cells which are cells that provide cover but do not have units on them. first, if there are decor tiles matching those x/y coords, replace their kanims with lamps. then, go through the remaining cover_cells entries and add a matching new entry to decos.
			for i = #cover_cells, 1, -1 do
				local cell = cover_cells[i]
				for k, decor in pairs( self._levelOutput.decos ) do
					if decor.x and decor.y and (cell[1] == decor.x) and (cell[2]  == decor.y) then
						decor.kanim = "decor_ko_office_lamp"
						local changed_cell = {decor.x, decor.y}
						table.insert(changed_cells, changed_cell)
						table.remove(cover_cells, i)
					end
				end
			end
			for i, cell in pairs(cover_cells) do		
				local new_lamp = {
				x = cell[1],
				y = cell[2],
				kanim = "decor_ko_office_lamp",
				facing = 2,
				}
				table.insert(self._levelOutput.decos, new_lamp)
				table.insert(changed_cells, cell)
			end
		end

				
		-- go back to the list of cells and remove sightblock, everywhere we've put a lamp
		for i, entry in pairs(self._levelOutput.map) do
			if type(entry) == "table" then
				for i, subentry in pairs(entry) do
					if subentry.sightblock and subentry.x and subentry.y then
						for k,v in pairs(changed_cells) do
							if (v[1] == subentry.x) and (v[2] == subentry.y) then
								subentry.sightblock = 0
							end
						end
					end
				end
			end
		end				
				
		oldInit( self, params, levelData, ... ) --for some reason, sightblock needs to be changed before oldInit to take effect, cover after oldInit
			
		-- go back to the list of cells and remove cover everywhere we've put a lamp
		for i, entry in pairs(self._levelOutput.map) do
			if type(entry) == "table" then
				for i, subentry in pairs(entry) do
					if subentry.cover and subentry.x and subentry.y then
						for k,v in pairs(changed_cells) do
							if (v[1] == subentry.x) and (v[2] == subentry.y) then
								-- log:write("LOG CHANGING COVER")
								subentry.cover = 0
								subentry.sightblock = 0
								-- log:write(util.stringize(subentry,3))
							end
						end
					end
				end
			end
		end
		
	end	
	
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
