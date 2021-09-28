local ArenaData = class("ArenaData")

function ArenaData:ctor()
	self.maxHistory = 0
end
function ArenaData:getMaxHistory()
	return self.maxHistory or 0
end

function ArenaData:setMaxHistory(max)
	self.maxHistory = max
end

return ArenaData

