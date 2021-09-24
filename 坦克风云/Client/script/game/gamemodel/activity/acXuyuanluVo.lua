acXuyuanluVo=activityVo:new()
function acXuyuanluVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acXuyuanluVo:updateSpecialData(data)

	if data.speakVate then
		self.speakVate = data.speakVate
	end
	
	if data.version then
		self.version = data.version
	end
	
	if self.goldTimes== nil then
		self.goldTimes = {}
	end
	if data.goldTimes then
		self.goldTimes = data.goldTimes
	end

	if self.goldReward == nil then
		self.goldReward = {}
	end
	if data.goldReward then
		self.goldReward = data.goldReward
	end

	if self.resourceTask==nil then
		self.resourceTask = {}
	end
	if data.resourceTask then
		self.resourceTask = data.resourceTask
	end

	if self.lastTime ==nil then
		self.lastTime = 0
	end

	if data.t then
		self.lastTime = data.t
	end

	if data.v then
		self.goldWishNum = data.v
	end

	if data.p then
		self.propWishNum = data.p
	end

	if self.propTask==nil then
		self.propTask = {{0,0,0},1,{0,0,0}}
	end

	if data.m then
		self.propTask = data.m
	end

	if data.br then
		self.chatGoods=data.br
	end

	if self.goldHistory == nil then
		self.goldHistory = {}
	end
	if data.rr then
		self.goldHistory = data.rr
	end

	if G_isToday(self.lastTime)==false then
		self.lastTime = base.serverTime
		self.propTask = {{0,0,0},1,{0,0,0}}
	end

end
