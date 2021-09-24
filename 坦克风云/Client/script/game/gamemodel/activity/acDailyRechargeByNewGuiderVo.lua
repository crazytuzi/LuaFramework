acDailyRechargeByNewGuiderVo=activityVo:new()

function acDailyRechargeByNewGuiderVo:updateSpecialData(data)
	if data then
	    if self.rewardCfg == nil then
	      self.rewardCfg = {}
	    end

	    if self.rewardCfg["reward"] == nil then
	      self.rewardCfg["reward"] = {}
	    end

	    if self.rewardCfg["cost"] == nil then
	      self.rewardCfg["cost"] = {}
	    end
	    if self.flickCfg == nil then
	    	self.flickCfg ={}
	    end

	    if data.r then
	    	self.r = data.r
	    end
	    if self.r == nil then
	    	self.r = {}
	    end
	    if data._activeCfg then
		    if data._activeCfg.reward ~= nil then
		      self.rewardCfg["reward"] = data._activeCfg.reward
		    end
		    
		    if data._activeCfg.cost ~= nil then
		      self.rewardCfg["cost"] = data._activeCfg.cost
		    end
		    
		    if data._activeCfg.version then
		      self.version =data._activeCfg.version
		    end

		    if data._activeCfg.flickReward1 then
		    	self.flickCfg = data._activeCfg.flickReward1
		    end
		end
	    -- t --上一次充值当天凌晨的时间戳
	    -- c -- 当日领奖次数
	    -- v -- 当日充值总额
	    if G_isToday(self.t) == true then
	       self.refreshTs = G_getWeeTs(self.t)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
	    else
	       self.t = G_getWeeTs(base.serverTime)
	       self.c = 0
	       self.r ={}
	       self.v = 0
	       self.refreshTs = G_getWeeTs(base.serverTime)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
	    end
	    self.refresh = false --排行榜结束排名后是否已刷新过数据
	end
end


function acDailyRechargeByNewGuiderVo:initRefresh()
    self.needRefresh = true -- 排行榜结束排名后是否需要刷新数据（比如排行结束后）   这里是从前一天到第二天时需要刷新数据
end