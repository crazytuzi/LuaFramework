newSignInVo={}
function newSignInVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function newSignInVo:initWithData(data)
	if newSignInCfg then
		self.reSignLimit  = newSignInCfg.reSignLimit--补签次数上限
		self.reSignGoldTb = newSignInCfg.reSignGold--补签所需金币（所需金币随补签次数变高）
		self.totalReward  = newSignInCfg.totalReward --累计签到奖励
		self.signAwardTb  = newSignInCfg.sign
	end

	if data and data.signTimes then--当月签到次数
		self.signTimes = data.signTimes
	end
	if not self.signTimes then
		self.signTimes = 0
	end
	
	if data and data.resignTimes then
		self.resignTimes = data.resignTimes
	end
	if not self.resignTimes then--当月已补签的次数
		self.resignTimes = 0
	end

	if not self.curMonTH then
		self.curMonTH=G_getDate(base.serverTime).month
	end
	-- print("self.curMonTH----->>>",self.curMonTH)
	-- if self.reSignLimit and self.resignTimes then--当前月剩余补签次数
	-- 	-- self.checkInAgainNum = self.reSignLimit - self.resignTimes
	-- else
	-- 	self.checkInAgainNum = 0
	-- end

	if self.signTimes then
		local date=G_getDate(base.serverTime)
		self.checkInAgainNum = date.day - self.signTimes >=0 and  date.day - self.signTimes or 0--当前月剩余补签次数
	end

	if data and data.signST then--上次签到时间戳
		self.signST = data.signST
	end
	if not self.signST then
		self.signST = 0
	end

	if data and data.rtb then--当月累计签到领取状态
		self.rtb = data.rtb
	end
	if not self.rtb then
		self.rtb = {}
	end

	if data and data.ver then--ver: 对应签到奖励配置表，后端从0计算返回，所以前端默认 + 1
		self.ver = data.ver + 1
	end
	if not self.ver then
		self.ver = 1
	end
end

function newSignInVo:clear(isSpec)
	self.signTimes       = nil
	self.resignTimes     = nil
	self.checkInAgainNum = nil
	self.rtb             = nil
	self.curMonTH = nil
	-- self.ver             = self.ver % SizeOfTable(self.signAwardTb) + 1
	if not isSpec then
		self.signST      = nil
	end
end