--[[
	EPGP
	Game Data Extraction
	Jug <jug@mangband.org>
--]]

-- Return all players in the current raid/group
function GetRaidMembers()
	raid = {}
	-- The current player is always a member
	me = Inspect.Unit.Detail("player")
	if me then
		table.insert(raid, me.name)
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
				table.insert(raid, member)
			end
		end
	end
	return raid
end