--[[
--	Watches action packets for a weaponskill finish
--	sends a chat message and plays a sound on receipt
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

local mode = "all" --off, all, list
local lists = {}
lists["watch"] = T{}
lists["ignore"]  = T{}

settings = {}
settings.sound = "level_up.wav";

function is_in_party(id)
    local party = windower.ffxi.get_party()

    for k, v in pairs (party) do
        if (type(v) == "table") then
            if (v.mob) then
                if id == v.mob.id then
					--if the name is not on the list OR the name is on the ignore list return false
					--this kinda overloads the function to do two things
					--need to check for both lists being nil
					if (mode == "list" and lists["watch"] and not (lists["watch"]:contains(v.name:lower()))) or (lists["ignore"] and lists["ignore"]:contains(v.name)) then
						return false
					end

					return true
				end
            end
        end
    end

    return false
end

windower.register_event('incoming chunk',function(id,data)
	--watch for action packets
	if mode == "off" then
		return
	end

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
		if p.category == 3  and is_in_party(p.actor_id) then
			--need to add checks to ignore weapon bash
			windower.add_to_chat(207,"Weaponskill FINISH")
			windower.play_sound(windower.addon_path..'sounds/' .. settings.sound)
		end
 	end
end)

windower.register_event('addon command', function(...)
	local args = T{...}:map(string.lower)
	local cmd = args[1]
	args:remove(1)
	local argc = #args
	if cmd == "mode" then
		windower.add_to_chat(207,"scwatch mode: "..mode)
	elseif T{"off","all","list"}:contains(cmd) then
		mode = cmd
		windower.add_to_chat(207,"scwatch mode changed to: "..mode)
	elseif T{"watch","ignore"}:contains(cmd) then
		if (args[1] and (not lists[cmd] or not lists[cmd]:contains(args[1])) ) then
			table.insert(lists[cmd],args[1])
			windower.add_to_chat(207,"scwatch added: "..args[1].." to "..cmd.." list.")
		end
	elseif T{"clear"}:contains(cmd) and T{"watch","ignore"}:contains(args[1]) then
		lists[args[1]] = T{}
		windower.add_to_chat(207,"scwatch cleared table: "..args[1])
	end
	--add command to print watch list
end)