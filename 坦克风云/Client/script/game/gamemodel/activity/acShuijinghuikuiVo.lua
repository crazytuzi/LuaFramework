acShuijinghuikuiVo=activityVo:new()
function acShuijinghuikuiVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acShuijinghuikuiVo:updateSpecialData(data)

	--金币：水晶 = 1:1000 小于1向下取整
    -- gemsVate = 1000,
    -- --每日首充可以领取的水晶
    -- dailyGold = 1000,

	if data.gemsVate then
		self.gemsVate = data.gemsVate
	end

	if data.dailyGold then
		self.dailyGold = data.dailyGold
	end

	if self.rechargeNum == nil then
		self.rechargeNum = 0
	end
	if data.m then
		self.rechargeNum = data.m
	end

	if self.lastTime == nil then
		self.lastTime = 0 
	end
	if data.t then
		self.lastTime = data.t
	end

	if self.dailyRecharge == nil then
		self.dailyRecharge = 0
	end
	if data.v then
		self.dailyRecharge = data.v
	end

	if G_isToday(self.lastTime)==false then
		self.dailyRecharge=0
	end
end