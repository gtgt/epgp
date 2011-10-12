--[[
EPGP data structures and calculations.
  EP = Effort Points
  GP = Gear Points
  PR = Loot Priority
--]]

-- Global EPGP Constants
EPGP = {
	baseGP = 100, -- Must be greater than zero
	minEP = 1000,
}

-- Per player EPGP data
PlayerEPGP = {
	EP = 0,
	realGP = 0,
	active = false,
}

-- Get/Set current GP
function PlayerEPGP:GetGP()
	return self.realGP + EPGP.baseGP
end
function PlayerEPGP:SetGP(gp)
	if gp < 0 then gp = 0 end
	self.realGP = gp
end
-- Increment GP
function PlayerEPGP:IncGP(gp)
	-- Sanity
	if gp < 1 then return end
	-- Add to realGP
	self.realGP = self.realGP + gp
end

-- Get/Set current EP
function PlayerEPGP:GetEP()
	return self.EP
end
function PlayerEPGP:SetEP(ep)
	if ep < EPGP.minEP then ep = EPGP.minEP end	
	self.EP = ep
end

-- Get current PR
function PlayerEPGP:GetPR()
	return self.GetEP() / self.GetGP()
end

-- Guild EPGP data
GuildEPGP = {
	-- per player EPGP data	
	players = {}
}

-- Do decay
-- Applies decay across all players. percentage is an integer, 1 to 100
-- The "active" state of the player is not considered, decay occurs if the player
-- is in the raid or not.
function GuildEPGP:ApplyDecay(percentage)
	-- Sanity
	if percentage < 1 or percentage > 100 then return end 
	-- Iterate over each player
	for player, data in pairs(self.players) do
		data.SetEP( data.GetEP() * ((100 - percentage) / 100) )
	end
end

-- Add some EP across all currently active players
function GuildEPGP:AddEP(ep)
	-- Sanity
	if ep < 0 then return end
	-- Iterate over all "active" players
	for player, data in pairs(self.players) do
		if data.active then
			data.SetEP(data.GetEP() + ep)
		end
	end
end

-- Add GP to a specific player
function GuildEPGP:AddGP(player, gp)
	-- Sanity
	if not player then return end
	-- Add GP
	p = self.players.player
	if p then
		p.IncGP(gp)
	end
end
