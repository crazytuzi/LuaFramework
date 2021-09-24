acCustomVo = activityVo:new()

function acCustomVo:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end

function acCustomVo:updateSpecialData(data)
	if data == nil then
		return
	end
	if data.activeTitle then
		self.activeTitle = data.activeTitle
	end
	if data.activeDesc then
		self.activeDesc = data.activeDesc
	end
	if data.activeType then
		self.activeType = data.activeType
	end
	-- if data.version then
		-- self.version = data.version
	-- end
	if data.openLv then
		self.openLv = data.openLv
	end
	if data.openVip then
		self.openVip = data.openVip
	end
	if data.shopList then
		self.shopList = data.shopList
	end
	if data.limit then
		self.limit = data.limit
	end
	if data.cost then
		self.cost = data.cost
	end
	if data.rd then
		self.buyNumTb = data.rd
	end
	if data.rechargeGold then
		self.rechargeGoldLimit = data.rechargeGold
	end
	if data.v then
		self.rechargeGoldNum = data.v
	end
end