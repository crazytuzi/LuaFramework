acMjcsVo=activityVo:new()

function acMjcsVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acMjcsVo:updateSpecialData(data)
	if data then
		if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if data.t then
        	self.rewardTime=data.t
        end
		if data.tr then
            self.task=data.tr  -- 任务
        end
        if data.c then
        	self.cost=data.c   -- 消费金额
        end
        if not self.cost then
			self.cost=0
		end
		if data.v then
			self.recharge=data.v  -- 充值
		end
		if data.bs then
			self.buyFromShop=data.bs   --商店购买
		end
		if not self.buyFromShop then
			self.buyFromShop={}
		end
		if data.logn then
			self.loginDay=data.logn --登录任务
		end
		if not self.loginDay then
			self.loginDay={0,0,0}
		end
		if data.cn then
			self.receiptsNum=data.cn  -- 充值任务，领取次数
		end
	end
end