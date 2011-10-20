--[[
	game.lua
	Game Data Extraction
--]]

-- Class colours
ClassColours = {
	["mage"] = {r = 0.41, g = 0.29, b = 0.52},
	["cleric"] = {r = 0.41, g = 0.65, b = 0.25},
	["rogue"] = {r = 0.89, g = 0.80, b = 0.40},
	["warrior"] = {r = 0.58, g = 0.17, b = 0.16}
}

-- Return all players in the current raid/group
function GetRaidMembers(includeTarget)
	raid = {}
	-- The current player is always a member
	me = Inspect.Unit.Detail("player")
	if me then
		table.insert(raid, {["name"] = me.name, ["calling"] = me.calling})
	end
	-- The current players target becomes a member
	if includeTarget then 
		target = Inspect.Unit.Detail("player.target")
		if target and target.player then
			table.insert(raid, {["name"] = target.name, 
				["calling"] = target.calling})
		end
	end
	-- Brute force search all group specifiers
	for i = 1, 20 do
		unit = Inspect.Unit.Detail(string.format("group%02d", i))
		if unit then
			-- We have a group member
			p = { ["name"] = unit.name, ["calling"] = unit.calling }
			table.insert(raid, p)
		end
	end
	return raid
end
