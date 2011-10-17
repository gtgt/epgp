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
function GetRaidMembers()
	raid = {}
	-- The current player is always a member
	me = Inspect.Unit.Detail("player")
	if me then
		table.insert(raid, {["name"] = me.name, ["calling"] = me.calling})
	end
	-- The current players target becomes a member
	target = Inspect.Unit.Detail("player.target")
	if target and target.player then
		table.insert(raid, {["name"] = target.name, ["calling"] = target.calling})
	end
	-- Grab all other group members
	units = Inspect.Unit.List()
	for id,specifier in pairs(units) do
		-- Get further detail on group specifiers
		group = string.match(specifier, "group(%d+)$")
		if group then
			member = Inspect.Unit.Detail(specifier)
			if member then
				-- We have a group member
				p = { ["name"] = member.name, ["calling"] = member.calling }
				table.insert(raid, p)
			end
		end
	end
	return raid
end
