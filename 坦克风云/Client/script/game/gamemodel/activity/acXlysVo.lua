-- @Author hj
-- @Description 训练有素数据模型
-- @Date 2018-07-02

acXlysVo = activityVo:new()

function acXlysVo:new( ... )
	local nc={
	}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acXlysVo:updateSpecialData(data)

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
		if data._activeCfg.taskGroup then
			self.taskList = data._activeCfg.taskGroup
		end
		if data._activeCfg.cost then
			self.cost = data._activeCfg.cost 
		end
		if data._activeCfg.cost2 then
			self.cost2 = data._activeCfg.cost2
		end
		if data._activeCfg.groupsTotalScore then
			self.groupsTotalScore = data._activeCfg.groupsTotalScore
		end
		if data._activeCfg.rewardAll then
			self.rewardAll = data._activeCfg.rewardAll
		end
		if data._activeCfg.rewardPart then
			self.rewardPart = data._activeCfg.rewardPart
		end
		if data._activeCfg.reward then
			self.reward = data._activeCfg.reward 
		end
	end

	-- 每一项的当前积分
	if data.rd then
		self.rd = data.rd
	end

	-- 每一项任务的领取状态
	if data.sr then
		self.sr = data.sr
	end

	-- 训练次数和洗练次数
	if data.tk then
		self.tk = data.tk
	end
	-- 任务奖励领取状态
	if data.tr then
		self.tr = data.tr
	end
	
	-- 首抽免费
	if data.f then
        self.firstFree = data.f
    end

    if not self.firstFree then
        self.firstFree = 0
    end

    --上次抽奖的时间，用于跨天重置免费次数
    if data.t then 
       self.lastTime=data.t
    end

    if data.allRe then
    	self.allReward = data.allRe
    end

    if data.part then
    	self.partReward = data.part
    end

end