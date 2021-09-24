--周年庆活动
acAnniversaryVo=activityVo:new()
function acAnniversaryVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.rp=0
	nc.playTime=0
	nc.friendNum=0
	nc.costGem=0
	nc.lastBuy=0
	nc.costReward={}
	nc.gameReward={}
	nc.rewardCfgCost={}
	nc.costCfg={}
	nc.rewardCfgGame={}
	return nc
end

function acAnniversaryVo:updateSpecialData(data)
	--下面是活动数据
	--累计获取军功数
	if(data.rp)then
		self.rp=tonumber(data.rp)
	end
	--总游戏时间
	if(data.pt)then
		self.playTime=tonumber(data.pt)
	end
	--好友数
	if(data.fc)then
		self.friendNum=tonumber(data.fc)
	end
	--今日消费金币
	if(data.v)then
		self.costGem=tonumber(data.v)
	end
	--消费奖励的领取情况
	if(data.cr)then
		self.costReward=data.cr
	end
	--游戏内成就的领取情况
	if(data.rd)then
		self.gameReward=data.rd
	end
	--上次消费金币的时间
	if(data.t)then
		self.lastBuy=tonumber(data.t)
		if(self.lastBuy<G_getWeeTs(base.serverTime))then
			self.costGem=0
			self.costReward={}
		end
	end
	--下面是活动配置
	--消费奖励配置
	if(data.creward)then
		self.rewardCfgCost=data.creward
	end
	--消费档次
	if(data.cost)then
		self.costCfg=data.cost
	end
	--游戏内成就奖励
	if(data.reward)then
		self.rewardCfgGame=data.reward
	end
end