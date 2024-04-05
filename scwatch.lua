--[[
--	Watches action packets for a weaponskill finish
--	sends a chat message on receipt
--
--]]

_addon.name = 'scwatch'
_addon.author = 'ainais'
_addon.version = '0.0.1'
_addon.commands = {'scwatch', 'scw'}

require('logger')
res = require('resources')
--files = require('files')
packets = require('packets')
--config = require('config')

windower.register_event('incoming chunk',function(id,data)
	--watch for action packets
	if id == 0x028 then
		--need to add checks to ignore players not in your party or alliance
		local p = windower.packets.parse_action(data)
		--[[
		if T{3,7,8}:contains(p.category) then
			windower.add_to_chat(207, id .. " Packet: \n"..T(p):tovstring())
		end
		--]]
		if p.category == 3 then
			--need to add checks to ignore weapon bash
			windower.add_to_chat(207,"Weaponskill FINISH")
			--windower.add_to_chat(207, id .. " Packet: \n"..T(p):tovstring())
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
