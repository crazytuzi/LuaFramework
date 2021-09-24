acCallsVo=activityVo:new()
function acCallsVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acCallsVo:updateSpecialData(data)
	if self.money == nil then
		self.money = {}
	end

	if data.money ~= nil then
		self.money = data.money
	end


	if self.vip == nil then
		self.vip = {}
	end

	if data.vip ~= nil then
		self.vip = data.vip
	end 

	if self.onlineDays == nil then
		self.onlineDays = 999
	end

	if data.day ~= nil then
		self.onlineDays = data.day
	end

    -- 订单号
	if self.tId == nil then
		self.tId = 0
	end

	if data.tId ~= nil then
		self.tId = data.tId
	end

	-- 订单状态(0代表不在处理中，1代表正在处理中)
	if self.tState == nil then
		self.tState = 3
	end

	if data.ls ~= nil then
		self.tState = tonumber(data.ls)
	end
end