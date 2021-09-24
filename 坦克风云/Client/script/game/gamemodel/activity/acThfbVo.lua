-- @Author hj
-- @Description 特惠风暴数据模型
-- @Date 2018-05-16

acThfbVo = activityVo:new()
function acThfbVo:new( ... )
	local nc={
	}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acThfbVo:updateSpecialData(data)
	if data == nil then
		return
	end

	if data._activeCfg then
		if data._activeCfg.openLevel then
			self.openLevel = data._activeCfg.openLevel
		end
		if data._activeCfg.buyLimit then
			self.buyLimit = data._activeCfg.buyLimit
		end
		if data._activeCfg.task then
			self.task = data._activeCfg.task
		end
		if data._activeCfg.reward then
			self.reward = data._activeCfg.reward
		end
		if data._activeCfg.cost then
			self.cost = data._activeCfg.cost
		end
		if data._activeCfg.name then
			self.name = data._activeCfg.name
		end
		if data._activeCfg.version then
	      self.version = data._activeCfg.version
	    end
	end

	-- 已领取的任务奖励
	if data.tr then
		self.tr = data.tr
	end
	-- 每个礼包的购买次数
	if data.rd then
		self.rd = data.rd
	end
	-- 每个礼包的折扣
	if data.dis then
		self.dis = data.dis
	end
	-- 每个任务完成次数
	if data.tk then
		self.tk = data.tk
	end
	
end