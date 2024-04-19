--[[
--	Watches action packets for a weaponskill finish
--	sends a chat message on receipt
--
--]]

_addon.name = 'scwatch'
_addon.author = 'ainais'
_addon.version = '0.1.0'
_addon.commands = {'scwatch', 'scw'}

require('logger')
res = require('resources')
--files = require('files')
packets = require('packets')
--config = require('config')

local watched_players = T{}

settings = {}
settings.sound = "level_up.wav";

function is_in_party(id)
    local party = windower.ffxi.get_party()

    for k, v in pairs (party) do
        if (type(v) == "table") then
            if (v.mob) then
                if id == v.mob.id then
					return true
				end
            end
        end
    end

    return false
end

windower.register_event('incoming chunk',function(id,data)
	--watch for action packets
	if id == 0x028 then
		--[[
24557 16:28:5540 Packet:
24558 {
24559     ["targets"]={
24560         [1]={
24561             ["id"]=17409796,
24562             ["actions"]={
24563                 [1]={
24564                     ["spike_effect_param"]=0,
24565                     ["add_effect_message"]=0,
24566                     ["message"]=110,
24567                     ["effect"]=0,
24568                     ["reaction"]=0,
24569                     ["add_effect_param"]=0,
24570                     ["stagger"]=2,
24571                     ["unknown"]=0,
24572                     ["add_effect_effect"]=0,
24573                     ["spike_effect_effect"]=0,
24574                     ["has_spike_effect"]=false,
24575                     ["spike_effect_animation"]=0,
24576                     ["has_add_effect"]=false,
24577                     ["knockback"]=0,
24578                     ["add_effect_animation"]=0,
24579                     ["animation"]=185,
24580                     ["spike_effect_message"]=0,
24581                     ["param"]=50
24582                 }
24583             },
24584             ["action_count"]=1
24585         }
24586     },
24587     ["unknown"]=0,
24588     ["target_count"]=1,
24589     ["recast"]=0,
24590     ["category"]=3,
24591     ["actor_id"]=11091,
24592     ["param"]=46
24593 }
		--]]
		local p = windower.packets.parse_action(data)
		--[[DEBUG
			if T{3,7,8}:contains(p.category) then
				windower.add_to_chat(207, id .. " Packet: \n"..T(p):tovstring())
			end
		--]]

		--checks to ignore players not in your party or alliance
		if (is_in_party(p.actor_id)) then
			if p.category == 3 then
				--need to add checks to ignore weapon bash
				windower.add_to_chat(207,"Weaponskill FINISH")
				windower.play_sound(windower.addon_path..'sounds/' .. settings.sound)
			end
		end
 	end
end)

windower.register_event('addon command', function(...)
	local args = T{...}:map(string.lower)
    	local cmd = args[1]
    	args:remove(1)
    	local argc = #args
	--add command to toggle modes (watch all or watch list)
	--add command to watch specific player names
	--add command to print watch list
end)
