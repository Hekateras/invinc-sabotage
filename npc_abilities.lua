local mathutil = include( "modules/mathutil" )
local array = include( "modules/array" )
local util = include( "modules/util" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include( "client_defs" )
local mainframe = include( "sim/mainframe" )
local modifiers = include( "sim/modifiers" )
local mission_util = include( "sim/missions/mission_util" )
local serverdefs = include("modules/serverdefs")
local mainframe_common = include("sim/abilities/mainframe_common")
local npc_abilities = include("sim/abilities/npc_abilities")
local unitghost = include( "sim/unitghost" )
local simfactory = include( "sim/simfactory" )
local unitdefs = include( "sim/unitdefs" )
local speechdefs = include("sim/speechdefs")
-- local rand = include( "modules/rand" )

local DEFAULT_ABILITY = mainframe_common.DEFAULT_ABILITY

-- actual implementation of specoops
local worldgen = include("sim/worldgen")
local generateThreats_old = worldgen.generateThreats

function worldgen.generateThreats( cxt, spawnTable, spawnList, ... )
	if not spawnList then
		spawnList = simdefs.SPAWN_TABLE[cxt.params.difficultyOptions.spawnTable][ cxt.params.difficulty ]
    end
	
    -- if specoops, replace non-vip spawns with specops
    if cxt.params.agency.sabotageDaemons and array.find( cxt.params.agency.sabotageDaemons, "sabotage_specoops" ) then
	
		local oldSpawnTable = spawnTable
		spawnTable = {}
		
    	--log:write("[SABOTAGE] Applying SpecOops: "..util.stringize(spawnTable, 4))
    	for unitTier, unitTable in pairs(oldSpawnTable) do
    		spawnTable[unitTier] = {{ "ko_specops", 100 }}
    	end
    end

    return generateThreats_old( cxt, spawnTable, spawnList, ... )
end

-- this is arcane to me, but it works in AGP so..? -Sizzle
local function generateThreatsWrapper( ... )
	return worldgen.generateThreats( ... )
end

upvalueUtil.findAndReplace( worldgen.worlds.ftm.generateUnits, "generateThreats", generateThreatsWrapper )

local createSabotageDaemon = function( stringTbl, override )
	local extendable = override or mainframe_common.createDaemon( stringTbl )

	return util.extend( extendable )
	{
		sabotageDaemon = true,
		noDaemonReversal = true,
	}
end
local daemon_strings = STRINGS.SABOTAGE.DAEMONS

-------------
local daemons = {
	-- base game extended daemons
	sabotage_modulate = createSabotageDaemon( STRINGS.DAEMONS.ALERTMODULATE, npc_abilities.alertModulate ),
	sabotage_portcullis = createSabotageDaemon( STRINGS.DLC1.DAEMONS.ALERT_PORTCULLIS, npc_abilities.alertportcullis),
	sabotage_chiton_2 = createSabotageDaemon( STRINGS.DLC1.DAEMONS.CHITON_2, npc_abilities.chitonAlarm_2),
	-- base game instant daemons
	sabotage_bruteForce = createSabotageDaemon( STRINGS.DAEMONS.ALERTBLOWFISH, npc_abilities.alertBruteForce ),
	sabotage_duplicator = createSabotageDaemon( STRINGS.DAEMONS.ALERTFRACTAL, npc_abilities.alertDuplicator ),

	-- copied and tweaked from Alert daemon from PE by wodzu_93
	sabotage_alert = util.extend( createSabotageDaemon( daemon_strings.ALERT ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_alert.png",  -- just reuse PE kwad...
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		
		ENDLESS_DAEMONS = false,
		PROGRAM_LIST = false,
		OMNI_PROGRAM_LIST_EASY = false,
		OMNI_PROGRAM_LIST = false,
		REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if not unit:getTraits().vip and not unit:isAlerted() then
					unit:setAlerted(true)
    	        			local x0, y0 = unit:getLocation()
	            			sim:getNPC():spawnInterest(x0, y0, simdefs.SENSE_RADIO, simdefs.REASON_HUNTING, unit)
					sim:dispatchEvent( simdefs.EV_UNIT_ALERTED, { unitID = unit:getID() } )
					unit:getSim():emitSpeech( unit, speechdefs.HUNT_NOISE)
					sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit } )
				end
			end		
			
			sim:getNPC():removeAbility(sim, self) --despawn

        	end,

		onDespawnAbility = function( self, sim, unit )
		end,			
	},
	
	sabotage_labyrinth2 = util.extend( createSabotageDaemon( STRINGS.DAEMONS.LABYRINTH ) )
	{
		icon = "gui/icons/daemon_icons/Daemons00012.png",

		drain = 2,
		duration = 20,
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, self.duration)
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )	

            self._affectedUnits = {}
            for i, unit in pairs(sim:getPC():getUnits()) do
		        if unit:getMP() then
			        unit:addMP( -self.drain )
			        unit:addMPMax( -self.drain )
                    table.insert( self._affectedUnits, unit )
		        end
	        end

			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim )
            for i, unit in pairs( self._affectedUnits) do
                if unit:getMP() and unit:isValid() then
			        unit:addMP( self.drain )
			        unit:addMPMax( self.drain )
                end
            end

			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},	

	--copy of failsafe
	sabotage_echo2 = util.extend( createSabotageDaemon( daemon_strings.ECHO2 ) )
	{
		icon = "gui/icons/daemon_icons/Daemons00014.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, "-")
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
        end,

        onTrigger = function( self, sim, evType, evData, userUnit )
	    	if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				sim:triggerEvent(simdefs.TRG_RECAPTURE_DEVICES, { reboots = 1} )
            else
                DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
            end
        end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_START_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end			
	},
	
	sabotage_paradox2 = util.extend( createSabotageDaemon( STRINGS.DAEMONS.PARADOX ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0008.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		duration = 10,
		
		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, self.duration)
			sim:setMainframeLockout( true )
			sim:addTrigger( simdefs.TRG_END_TURN, self )				
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )	
		end,

		onDespawnAbility = function( self, sim )
			sim:setMainframeLockout( false )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},	

	sabotage_rubiks2 = util.extend( createSabotageDaemon( daemon_strings.RUBIKS2 ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0001.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		iceBoost = 2,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = self.activedesc, } )	
            sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 0.5 * cdefs.SECONDS )
			for _, unit in pairs( sim:getAllUnits() ) do
				unit:increaseIce(sim, self.iceBoost)
			end
			player:removeAbility(sim, self )
		end,

		onDespawnAbility = function( self, sim, unit )
		end,
	},
	
		-- copy from PE
		sabotage_lockdown = util.extend( createSabotageDaemon( daemon_strings.GATEKEEPER2) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_gatekeeper.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		duration = 20,

		ENDLESS_DAEMONS = false,
		PROGRAM_LIST = false,
		OMNI_PROGRAM_LIST_EASY = false,
		OMNI_PROGRAM_LIST = false,
		REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, self.duration)
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )
		
			if not sim:getPC():getTraits().gatekeeper then
				sim:getPC():getTraits().gatekeeper = 1
				local shouldUpdateLock = false
				sim:forEachCell(function( c )
					for i, exit in pairs( c.exits ) do
						if exit.door and not exit.closed and (exit.keybits == simdefs.DOOR_KEYS.ELEVATOR or exit.keybits == simdefs.DOOR_KEYS.ELEVATOR_INUSE) then
							local reverseExit = exit.cell.exits[ simquery.getReverseDirection( i ) ]
							exit.keybits = simdefs.DOOR_KEYS.ELEVATOR_INUSE						
							reverseExit.keybits = simdefs.DOOR_KEYS.ELEVATOR_INUSE
							sim:modifyExit( c, i, simdefs.EXITOP_CLOSE )
							sim:modifyExit( c, i, simdefs.EXITOP_LOCK )
							sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED, {cell=c, dir=i} )
							shouldUpdateLock = true
						elseif exit.door and exit.closed and (exit.keybits == simdefs.DOOR_KEYS.ELEVATOR or exit.keybits == simdefs.DOOR_KEYS.ELEVATOR_INUSE) then
							shouldUpdateLock = true
						elseif exit.door and not exit.closed and exit.keybits == simdefs.DOOR_KEYS.FINAL_LEVEL then 
							sim:modifyExit( c, i, simdefs.EXITOP_CLOSE )
							sim:modifyExit( c, i, simdefs.EXITOP_LOCK )
							sim:dispatchEvent( simdefs.EV_EXIT_MODIFIED, {cell=c, dir=i} )
						end
					end
				end )
				if shouldUpdateLock and (sim._elevator_inuse or 0) < self.duration then
					sim._elevator_inuse = self.duration
				end
			else
				sim:getPC():getTraits().gatekeeper = sim:getPC():getTraits().gatekeeper + 1
				if sim._elevator_inuse and sim._elevator_inuse < self.duration then
					sim._elevator_inuse = self.duration
				end
			end
			sim:addTrigger( simdefs.TRG_END_TURN, self )
        end,

		onDespawnAbility = function( self, sim )
			sim:getPC():getTraits().gatekeeper = sim:getPC():getTraits().gatekeeper - 1
			if sim:getPC():getTraits().gatekeeper <= 0 then
				sim:getPC():getTraits().gatekeeper = nil
			end
			sim:removeTrigger( simdefs.TRG_END_TURN, self )
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end,	
	},
	
	sabotage_validoops = util.extend( createSabotageDaemon( daemon_strings.VALIDOOPS ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0004.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=false, name = self.name, icon=self.icon, txt = self.activedesc, } )	
            sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 0.5 * cdefs.SECONDS )
			for _, unit in pairs( sim:getAllUnits() ) do
				if unit:getTraits().mainframe_iceMax and unit:getTraits().mainframe_ice and unit:getPlayerOwner() ~= sim:getPC() and unit:getTraits().mainframe_program then
					unit:getTraits().mainframe_program = "validate"
				end
			end
			player:removeAbility(sim, self )
		end,

		onDespawnAbility = function( self, sim, unit )
		end,
	},	
	
	sabotage_pinpoint = util.extend( createSabotageDaemon( daemon_strings.PINPOINT ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0007.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, '-')
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )
			sim:addTrigger( simdefs.TRG_END_TURN, self )
			sim:addTrigger( simdefs.TRG_START_TURN, self )	
        end,

        onTrigger = function( self, sim, evType, evData, userUnit )
	    	if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
	    		local agent = nil
	    		local agents = sim:getPC():getAgents()
	    		agent = agents[ sim:nextRand( 1, #agents ) ] 

				if agent then
					local x2,y2 = agent:getLocation()
					sim:getNPC():spawnInterest(x2,y2, simdefs.SENSE_RADIO,  simdefs.REASON_CAMERA, agent)
					agent:getSim():dispatchEvent( simdefs.EV_SHOW_DIALOG, { dialog = "locationDetectedDialog", dialogParams = { agent }} )
				end
            else
                DEFAULT_ABILITY.onTrigger( self, sim, evType, evData, userUnit )
            end
        end,

		onDespawnAbility = function( self, sim )
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
			sim:removeTrigger( simdefs.TRG_START_TURN, self )
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end		
	},	
	
	sabotage_nullcameras = util.extend( createSabotageDaemon( daemon_strings.NULLCAMERAS ) )
	{
		icon = "gui/icons/daemon_icons/Daemons00014.png", --Echo icon
		standardDaemon = false,
		reverseDaemon = false,
		permanent = true,
		
		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, '-')
			sim:getTags().nullcameras = true
			sim:addTrigger( simdefs.TRG_END_TURN, self )				
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )	
		end,

		onDespawnAbility = function( self, sim )
			sim:getTags().nullcameras = nil
			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},	

	sabotage_specoops = util.extend( createSabotageDaemon( daemon_strings.SPECOOPS ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_specoops.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		
		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=false, name = self.name, icon=self.icon, txt = self.activedesc, } )	
            sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 0.5 * cdefs.SECONDS )
			
            -- This changes the alarm level 3+4 guards. Starting guards changed in generateThreats.
			
			sim._patrolGuard = {{ "ko_specops", 100 }}

			player:removeAbility(sim, self )
		end,

		onDespawnAbility = function( self, sim )
		end,
	},	

	sabotage_brighter = util.extend( createSabotageDaemon( daemon_strings.BRIGHTER ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_brighten.png", -- custom icon plz?
		standardDaemon = false,
		reverseDaemon = false,
		permanent = true,
		
		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=false, name = self.name, icon=self.icon, txt = self.activedesc, } )	
            		sim:dispatchEvent( simdefs.EV_WAIT_DELAY, 0.5 * cdefs.SECONDS )
			
		-- this doesn't actually do anything.

			player:removeAbility(sim, self )
		end,

		onDespawnAbility = function( self, sim )
		end,
	},	
}

return daemons
