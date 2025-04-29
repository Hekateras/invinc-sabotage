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
local abilitydefs = include( "sim/abilitydefs" )
local mui = include( "mui/mui" )
local mui_defs = include( "mui/mui_defs" )
local mui_util = include( "mui/mui_util" )
local cdefs = include( "client_defs" )
local util = include( "client_util" )
local array = include( "modules/array" )
local modalDialog = include( "states/state-modal-dialog" )
local strings = include( "strings" )
local mission_util = include( "sim/missions/mission_util" )
-------------------------------------------------------
-- some pseudocode for the spawning
--ref: function simplayer:addMainframeAbility(sim, abilityID, hostUnit, reversalOdds )

-- local function spawnDaemonOnInput( noDaemonReversal = true,, blah2 )
	-- --when player inputs string into field:

-- -- make sure correct daemon is returned regardless of case typoes
	-- local fixedInput = util.tolower(inputString)
	-- local daemonID = daemonDict[fixedInput]
	-- if abilitydefs.lookupAbility(daemonID) then
		-- sim:getNPC():addMainframeAbility( sim, daemon, nil, 0)
	-- end
-- -- we never want these reversed! passing 0 here only sets  base reversal odds to zero and doesn't actually prevent reversal if player has e.g. Brimstone. Would need to add noDaemonReversal = true to the daemons to be extra sure.
-- end

local daemonDict = {

["blowfish2"] =	"sabotage_bruteForce",
["fractal2"] =	"sabotage_duplicator", 
["modulate2"] = "sabotage_modulate",
["portcullis2"] = "sabotage_portcullis",
["chiton2"] = "sabotage_chiton_2",
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

local storySituations = {["mid_1"] = true, ["mid_2"] = true, ["ending_1"] = true }

local select_daemon_dialog = class()

local function onClickSave( dialog )
	dialog.result = true
end

function select_daemon_dialog:init()
	local screen = mui.createScreen( "modal-select-daemons" )
	self._screen = screen
	self._list =  screen:findWidget("list")

	screen.binder.okBtn.onClick = util.makeDelegate( nil, onClickSave, self )
end

function select_daemon_dialog:onLoad()
	MOAIFmodDesigner.playSound(  cdefs.SOUND_HUD_MENU_POPUP )
	mui.activateScreen( self._screen )
end

function select_daemon_dialog:onUnload()
	MOAIFmodDesigner.playSound(  cdefs.SOUND_HUD_MENU_POPDOWN  )
	mui.deactivateScreen( self._screen )
end

function select_daemon_dialog:show()
	self.result = nil

	if not self._screen then
		self:init()
	end

	statemgr.activate( self )
	
	self._list:clearItems()
	self._list._scrollbar:setVisible( false )
	
	for k, v in pairs( daemonDict ) do
		local widget = self._list:addItem( v, "CheckOption" )
		widget.binder.widget:setText( k )
	end
	
	local txt = self._screen:findWidget("headerTxt")
	
	while self.result == nil do
		local c = 0
		
		for i, v in pairs(self._list:getItems()) do
			if v.widget.binder.widget:isChecked() then
				c = c + 1
			end
		end
		
		txt:setText(string.format("%d Daemons Selected", c))
	
		coroutine.yield()
	end
	
    statemgr.deactivate( self )
	
	local daemonSelection = {}
	
	for i, v in pairs(self._list:getItems()) do
		if v.widget.binder.widget:isChecked() then
			table.insert(daemonSelection, v.user_data)
		end
	end

	return daemonSelection
end

function select_daemon_dialog:isActive()
	return self._screen and self._screen:isActive()
end

if rawget(_G, "multiMod") then
	local oldVoteMission = multiMod.voteMission
	
	multiMod.voteMission = function( self, situationIndex, playerIndex, ... )
		if multiMod:isHost() and not playerIndex and abilitydefs.lookupAbility("sabotage_validoops") then
			self.campaign.agency.sabotageDaemons = select_daemon_dialog:show(  )
		end
		
		return oldVoteMission( self, situationIndex, playerIndex, ... )
	end
end

local mapScreen = include("states/state-map-screen")

local oldClosePreview = mapScreen.closePreview

function mapScreen:closePreview(preview_screen, situation, go_to_there, ...)
	if go_to_there and abilitydefs.lookupAbility("sabotage_validoops") and not (rawget(_G,"multiMod") and multiMod:getUplink()) then
		self._campaign.agency.sabotageDaemons = select_daemon_dialog:show(  )
	end
	-- set up specoops guard tableswap
	-- log:write("[SABOTAGE] Daemon list: "..util.stringize(self._campaign.agency.sabotageDaemons, 2))
	for i, daemon in pairs(self._campaign.agency.sabotageDaemons) do
		if daemon == "sabotage_specoops" then
			self._campaign.missionParams.specOops = true
			break
		end
	end

	oldClosePreview(self, preview_screen, situation, go_to_there, ...)
end

local AGENT_CONNECTION_DONE =
{       
trigger = "finishedAgentConnection",
fn = function( sim, evData )
    return true
end,
}

local hookFn_story = function( script, sim )

	script:waitFor( mission_util.UI_INITIALIZED )
	if storySituations[sim:getParams().situationName] then
		for i, daemonID in ipairs( sim:getParams().agency.sabotageDaemons ) do
			if abilitydefs.lookupAbility(daemonID) then
				sim:getNPC():addMainframeAbility( sim, daemonID, nil, 0)
			end
		end
	end
end

local hookFn_escape = function( script, sim )

	script:waitFor( AGENT_CONNECTION_DONE )
	if storySituations[sim:getParams().situationName] then
		for i, daemonID in ipairs( sim:getParams().agency.sabotageDaemons ) do
			if abilitydefs.lookupAbility(daemonID) then
				sim:getNPC():addMainframeAbility( sim, daemonID, nil, 0)
			end
		end
	end
end

local simengine = include("sim/engine")

local oldSimInit = simengine.init

simengine.init = function(self,...)
	oldSimInit(self, ...)
	
	if self:getParams().agency.sabotageDaemons then
		if storySituations[self:getParams().situationName] then
			self:getLevelScript():addHook( "SABOTAGE-DAEMONS-STORY", hookFn_story )
		else
			self:getLevelScript():addHook( "SABOTAGE-DAEMONS-ESCAPE", hookFn_escape )
		end
	end
end

local mainframe_panel = include("hud/mainframe_panel").panel
local oldAddMainframeProgram = mainframe_panel.addMainframeProgram
local oldRefresh = mainframe_panel.refresh

-- normal daemon { 140/255, 0, 0, 1 } #8C0000
-- reversed daemon { 0/255, 164/255, 0/255, 1 } #00A400
-- sabotage daemon orange? #8C5200 (close to a tetrad colour)
local CLR_SABOTAGE = { 140/255, 82/255, 0, 1 }

function mainframe_panel:addMainframeProgram( player, ability, idx, ... )
	local results = { oldAddMainframeProgram( self, player, ability, idx, ... ) }

	local widget = self._panel.binder:tryBind( "enemyAbility"..idx )
    if widget and player == self._hud._game.simCore:getNPC() and ability.is_sabotage_daemon then
    	widget.binder.btn:setColor( unpack(CLR_SABOTAGE) )
    end

    return unpack(results)
end

function mainframe_panel:refresh( ... )
	local results = { oldRefresh( self, ... ) }

	for i, widget in self._panel.binder:forEach( "enemyAbility" ) do
		local ability = self._hud._game.simCore:getNPC():getAbilities()[i]
		if ability and ability.is_sabotage_daemon then
			widget.binder.btn:setColor( unpack(CLR_SABOTAGE) )
		end
	end

	return unpack(results)
end
