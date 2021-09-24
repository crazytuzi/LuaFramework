acVipActionVo=activityVo:new()
function acVipActionVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.todayCharge=0			--今天充值的金额			
	self.totalCharge=0			--累计充值的金额
	self.todayGet={}				--今日奖励领取了几档
	self.totalGet=0		--累计奖励领取到第几档

	self.dayRewardCfg = {}
	self.dayCfg = {}
	self.totalRewardCfg = {}
	self.totalCfg = {}
	return nc
end

function acVipActionVo:updateSpecialData(data)
	if data.rd then -- 每日奖励配置
		self.dayRewardCfg = data.rd
	end

	if data.dayrecharge then -- 每日配置
		self.dayCfg = data.dayrecharge
	end

	if data.reward then -- 累计奖励配置
		self.totalRewardCfg = data.reward
	end

	if data.cost then -- 累计配置
		self.totalCfg = data.cost
	end


	if(data.r)then
		self.totalCharge=tonumber(data.r)
	end

    if(data.rc)then
		self.totalGet=tonumber(data.rc)
	end

	if G_isToday(self.t) == true then  -- self.t 代表当日最后一次充值时间
		if(data.v)then
			self.todayCharge=tonumber(data.v)
		end
		if(data.vc)then
			self.todayGet=data.vc
		end
        self.refreshTs = G_getWeeTs(self.t)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
    else
        self.t = G_getWeeTs(base.serverTime)
        self.todayCharge = 0
        self.todayGet = {}
        self.refreshTs = G_getWeeTs(base.serverTime)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
    end
    self.refresh = false --排行榜结束排名后是否已刷新过数据
end

function acVipActionVo:initRefresh()
    self.needRefresh = true -- 排行榜结束排名后是否需要刷新数据（比如排行结束后）   这里是从前一天到第二天时需要刷新数据
end