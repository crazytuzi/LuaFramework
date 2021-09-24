acMysteryBoxVo = activityVo:new()

function acMysteryBoxVo:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end

function acMysteryBoxVo:updateSpecialData(data)
	if data == nil then
		return
	end
	if data.activeTitle then
		self.activeTitle = data.activeTitle
	end
	if data.activeDesc then
		self.activeDesc = data.activeDesc
	end
	if data.shopList then
		self.shopList = data.shopList
	end
	if data.openLv then
		self.openLv = data.openLv
	end
	if data.openVip then
		self.openVip = data.openVip
	end
	if data.rd then
		self.rewardData = data.rd
	end
	-- if data.t then
	-- 	self.lastTimer = data.t
	-- end

	if type(self.refreshFunc) == "function" then
		self.refreshFunc()
	end
end