-- @Author hj
-- @Description 新春聚惠数据模型
-- @Date 2018-12-24

acXcjhVo = activityVo:new()

function acXcjhVo:new( ... )
	local nc={
	}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acXcjhVo:updateSpecialData(data)

	if data == nil then
		return
	end
	if data._activeCfg then
		if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
		if data._activeCfg.taskList then
			self.taskList = data._activeCfg.taskList
		end
		if data._activeCfg.cost then
			self.cost = data._activeCfg.cost
		end
		if data._activeCfg.cost5 then
			self.multiCost = data._activeCfg.cost5
		end
		if data._activeCfg.pool then
			self.pool = data._activeCfg.pool
		end
		if data._activeCfg.hxcfg then
			self.hxcfg = data._activeCfg.hxcfg
		end
		-- 组成大奖的数字个数
		if data._activeCfg.spRewardPicNum then
			self.spRewardPicNum = data._activeCfg.spRewardPicNum
		end
		if data._activeCfg.reward then
			self.reward = data._activeCfg.reward
		end
		if data._activeCfg.taskDay then
			self.taskDay = data._activeCfg.taskDay
		end
	end

	--上次抽奖的时间，用于跨天重置免费次数
    if data.t then 
       self.lastTime=data.t
    end

    -- 首抽免费
	if data.f then
        self.firstFree = data.f
    end

    -- 改奖道具
    if data.ac2 then
    	self.ac2 = data.ac2
    end

   	-- 任务奖励完成次数
	if data.tr then
		self.tr = data.tr
	end

	-- 任务奖励的领取状态
	if data.bn then
		self.status = data.bn
	end

	-- 奖券数据
	if data.p then
		self.p = data.p
	end

end