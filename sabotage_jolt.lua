local array = include( "modules/array" )
local util = include( "modules/util" )
local cdefs = include( "client_defs" )
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local abilityutil = include( "sim/abilities/abilityutil" )


local sabotage_jolt =
	{
		name = "SPAWN JOLT",
		--hotkey =  "abilityOverwatch",
		profile_icon = "gui/icons/item_icons/items_icon_small/icon-item_heart_monitor_small.png",
		alwaysShow = true,
		HUDpriority = 1,
		--usesAction = true,
		onTooltip = function( self, hud, sim, abilityOwner, abilityUser )
			return "SPAWN JOLT DAEMON"
		end,

		canUseAbility = function( self, sim, unit )

			if unit:getTraits().usedSabotageDaemon then 
				return false, "ALREADY SPAWNED DAEMON"
			end

			if unit:isKO() then
				return false, STRINGS.UI.REASON.UNIT_IS_KO
			end		

			return true
		end,
		
		executeAbility = function( self, sim, unit, ownerUnit, targetID )
			if unit:isValid() then
				sim:getNPC():addMainframeAbility( sim, "jolt", nil, 0)
				--bruteForce
				--validate
				unit:getTraits().usedSabotageDaemon = true
				sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = unit })

			end	
		end,
	}
return sabotage_jolt
