--超级武器的武器数据
swChallengeVo={}
function swChallengeVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.curClearPos=0 		--当前这一次已经通过的关卡
	self.maxClearPos=0		--历史最大通过的关卡
	self.hasCNum=0			--已经挑战次数
	self.buyCNum=0			--已经购买挑战次数
	self.resetNum=0			--已经重置次数
	self.lastRestTime=0		--上次重置时间
	self.raidStartIndex=0	--扫荡开始关卡
	self.raidEndIndex=0		--扫荡结束关卡
	self.raidEndTime=0		--扫荡结束时间
	return nc
end

function swChallengeVo:initWithData(param)
	if param then
		if param.pos then
			self.curClearPos=tonumber(param.pos) or 0
		end
		if param.maxpos then
			self.maxClearPos=tonumber(param.maxpos) or 0
		end
		if param.failnum then
			self.hasCNum=tonumber(param.failnum) or 0
		end
		if param.buyfail then
			self.buyCNum=tonumber(param.buyfail) or 0
		end
		if param.buyrest then
			self.resetNum=tonumber(param.buyrest) or 0
		end
		if param.lastrest then
			self.lastRestTime=tonumber(param.lastrest) or 0
		end
		if param.sweepst then
			self.raidStartIndex=tonumber(param.sweepst) or 0
		end
		if param.sweepet then
			self.raidEndIndex=tonumber(param.sweepet) or 0
		end
		if param.sweepfin then
			self.raidEndTime=tonumber(param.sweepfin) or 0
		end
	end
end
