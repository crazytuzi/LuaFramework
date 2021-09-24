acFlashSaleVo = activityVo:new()

function acFlashSaleVo:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end

function acFlashSaleVo:updateSpecialData(data)
	if data == nil then
		return
	end
	if data._activeCfg then
		self.activeCfg = data._activeCfg
	end
	if data.lvl then
		self.playerLv = data.lvl
	end
	if data.rew then
		self.themeReward = data.rew
	end
	if data.creward then
		self.creward = data.creward
	end
	if data.free then
		self.free = data.free
	end
	if type(self.refreshFunc) == "function" then
		self.refreshFunc(data._getFlag)
	end
end