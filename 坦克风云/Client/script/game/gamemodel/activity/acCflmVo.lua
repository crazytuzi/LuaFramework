--2018春节充值活动春福临门
--author: Liang Qi
acCflmVo=activityVo:new()
function acCflmVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.lastRechargeTs=0		--上次充值的时间
	nc.rechargeTb={}		--每日充值数量
	nc.rechargetRewardTb={}	--每日充值奖励的领取情况
	nc.finalRewardGetTb={}	--终极大奖的领取情况
	nc.investType=nil		--购买基金的种类
	nc.buyTs=0				--购买基金的时间
	nc.lastGetTs=0			--上次领取基金奖励的时间
	nc.totalRecharge=0		--活动期间的总充值金额
	nc.investGetTb={}		--基金的领取情况
	nc.cfg=activityCfg.cflm[1]
	nc.version=1
	return nc
end

function acCflmVo:updateSpecialData(data)
	if data.et ~= nil then
		self.et = tonumber(data.et)
		if(self.et~=0)then
			self.et=self.et - 86400
		end
	end
	if(data.v)then
		self.totalRecharge=tonumber(data.v) or 0
	end
	if(data.cfg)then
		self.version=tonumber(data.cfg)
	end
	if(self.version)then
		self.cfg=activityCfg.cflm[self.version]
	end
	if(data.nc)then
		local nc=data.nc
		if(nc.v)then
			self.rechargeTb=nc.v
		end
		if(nc.lastGetTs)then
			self.lastGetTs=tonumber(nc.lastGetTs) or 0
		end
		if(nc.buyTs)then
			self.buyTs=tonumber(nc.buyTs) or 0
		end
		if(nc.rd)then
			self.rechargetRewardTb=nc.rd
		end
		if(nc.fundrd)then
			self.investGetTb=nc.fundrd
		end
		if(nc.lastRechargeTs)then
			self.lastRechargeTs=nc.lastRechargeTs
		end
		if(nc.investType)then
			self.investType=nc.investType
		end
		if(nc.final)then
			self.finalRewardGetTb=nc.final
		end
	end
end