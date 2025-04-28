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
local unitghost = include( "sim/unitghost" )
local simfactory = include( "sim/simfactory" )
local unitdefs = include( "sim/unitdefs" )
-- local rand = include( "modules/rand" )

-- helper stuff
local daemon_strings = {

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
}
-------------
return
{

	-- copied and tweaked from Alert daemon from PE by wodzu_93
	sabotage_alert = util.extend( createDaemon( daemon_strings.ALERT ) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_alert.png",  -- just reuse PE kwad...
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		noDaemonReversal = true,
		
		ENDLESS_DAEMONS = false,
		PROGRAM_LIST = false,
		OMNI_PROGRAM_LIST_EASY = false,
		OMNI_PROGRAM_LIST = false,
		REVERSE_DAEMONS = false,

		onSpawnAbility = function( self, sim, player )
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )

			for _, unit in ipairs(sim:getNPC():getUnits() ) do
				if not unit:getTraits().pacifist and not unit:isAlerted() then
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
	
	sabotage_labyrinth2 = util.extend( createDaemon( STRINGS.DAEMONS.LABYRINTH ) )
	{
		icon = "gui/icons/daemon_icons/Daemons00012.png",

		drain = 2,
		duration = 20,
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		noDaemonReversal = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, self.duration)
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { name = self.name, icon=self.icon, txt = self.activedesc } )	

            self._affectedUnits = {}
            for i, unit in pairs(sim:getPC():getUnits()) do
		        if unit:getMP() then
			        unit:addMP( -2 )
			        unit:addMPMax( -2 )
                    table.insert( self._affectedUnits, unit )
		        end
	        end

			sim:addTrigger( simdefs.TRG_END_TURN, self )	
		end,

		onDespawnAbility = function( self, sim )
            for i, unit in pairs( self._affectedUnits) do
                if unit:getMP() and unit:isValid() then
			        unit:addMP( 2 )
			        unit:addMPMax( 2 )
                end
            end

			sim:removeTrigger( simdefs.TRG_END_TURN, self )	
		end,

		executeTimedAbility = function( self, sim )
			sim:getNPC():removeAbility(sim, self )
		end	
	},	

	--copy of failsafe
	sabotage_echo2 = util.extend( createDaemon( daemon_strings.ECHO2	 ) )
	{
		icon = "gui/icons/daemon_icons/Daemons00014.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = true,
		noDaemonReversal = true,

		onSpawnAbility = function( self, sim, player )
			self.duration = self.getDuration(self, sim, "-")
			sim:dispatchEvent( simdefs.EV_SHOW_DAEMON, { showMainframe=true, name = self.name, icon=self.icon, txt = util.sformat(self.activedesc, self.duration ) } )
			sim:addTrigger( simdefs.TRG_START_TURN, self )
        end,

        onTrigger = function( self, sim, evType, evData, userUnit )
	    	if evType == simdefs.TRG_START_TURN and sim:getCurrentPlayer():isPC() then
				--ref: mission_util.doRecapturePresentation = function(script, sim, cyberlab, agent, climax, numItems)
				local script = sim:getLevelScript()
				mission_util.doRecapturePresentation(script, sim, nil, nil, nil, 1)
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
	
	sabotage_paradox2 = util.extend( createDaemon( STRINGS.DAEMONS.PARADOX ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0008.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		noDaemonReversal = true,
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

	sabotage_rubiks2 = util.extend( createDaemon( daemon_strings.RUBIKS2 ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0001.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		noDaemonReversal = true,
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
		sabotage_lockdown = util.extend( createDaemon( daemon_strings.GATEKEEPER2) )
	{
		icon = "gui/icons/daemon_icons/icon-daemon_gatekeeper.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		noDaemonReversal = true,
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
	
	sabotage_validoops = util.extend( createDaemon( daemon_strings.VALIDOOPS ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0004.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = false,
		noDaemonReversal = true,

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
	
	sabotage_pinpoint = util.extend( createDaemon( daemon_strings.PINPOINT ) )
	{
		icon = "gui/icons/daemon_icons/Daemons0007.png",
		standardDaemon = false,
		reverseDaemon = false,
		permanent = true,
		noDaemonReversal = true,

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
	
	sabotage_nullcameras = util.extend( createDaemon( daemon_strings.NULLCAMERAS ) )
	{
		icon = "gui/icons/daemon_icons/Daemons00014.png", --Echo icon
		standardDaemon = false,
		reverseDaemon = false,
		permanent = true,
		noDaemonReversal = true,
		
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
}
