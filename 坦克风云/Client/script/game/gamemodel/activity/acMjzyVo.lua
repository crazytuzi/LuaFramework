-- @Author hj
-- @Description 名将增援数据模型
-- @Date 2018-06-11

acMjzyVo = activityVo:new()

function acMjzyVo:new( ... )
	local nc={
	}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acMjzyVo:updateSpecialData(data)

	if data == nil then
		return
	end

	if data._activeCfg then
		if data._activeCfg.levelLimit then
			self.levelLimit = data._activeCfg.levelLimit
		end
		if data._activeCfg.hxcfg then
			self.hxcfg = data._activeCfg.hxcfg
		end
		if data._activeCfg.reward then
			self.reward = data._activeCfg.reward
		end
		if data._activeCfg.cost then
			self.cost = data._activeCfg.cost 
		end
		if data._activeCfg.cost2 then
			self.cost2 = data._activeCfg.cost2
		end
		if data._activeCfg.doubleRateCostNum then
			self.doubleRateCostNum = data._activeCfg.doubleRateCostNum
		end
		if data._activeCfg.shopList then
			self.shopList = data._activeCfg.shopList
		end
		if data._activeCfg.showList then
			self.showList = data._activeCfg.showList
		end
		if data._activeCfg.doubleRateCostNum then
			self.upRateCostNum = data._activeCfg.doubleRateCostNum 
		end
		if data._activeCfg.rewardExtra then
			self.rewardExtra = data._activeCfg.rewardExtra 
		end
		if data._activeCfg.shopList then
			self.shopList = data._activeCfg.shopList 
		end
		if data._activeCfg.showRate then
			self.showRate = data._activeCfg.showRate
		end
	end

	-- 商店购买次数
	if data.rd then
		self.rd = data.rd
	end
	
	-- 抽奖达到指定次数获取的奖励
	if data.re then
		self.re = data.re
	end

	-- 设置翻倍的将领
	if data.sid then
		self.sid = data.sid
	end

	-- 首抽免费
	if data.f then
        self.firstFree = data.f
    end

    if not self.firstFree then
        self.firstFree = 0
    end

	-- 抽奖次数 
    if data.c then
    	self.rewardNum = data.c
    end
    
    -- 商店数据
    if data.rd then
    	self.rd = data.rd	
    end

    --上次抽奖的时间，用于跨天重置免费次数
    if data.t then 
       self.lastTime=data.t
    end


end