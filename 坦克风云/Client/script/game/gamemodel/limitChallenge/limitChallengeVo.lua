-- @Author hj
-- @Date 2018-10-18
-- @Description 限时挑战数据处理模型

limitChallengeVo = dailyActivityVo:new()

function limitChallengeVo:new(type)
	local nc={
		updateFlag = false
	}
	setmetatable(nc,self)
	self.__index=self
	nc.type=type
	return nc
end


function limitChallengeVo:canReward()
	return false
end


function limitChallengeVo:updateData(data)

	-- 普通挑战积分
	if data.npoint then
		self.npoint = data.npoint
	end
	-- 普通挑战任务信息 
	if data.ninfo then
		self.ninfo = data.ninfo
	end
	-- 地狱挑战积分
	if data.hpoint then
		self.hpoint = data.hpoint
	end
	-- 地狱挑战任务信息
	if data.hinfo then
		self.hinfo = data.hinfo
	end
	-- 挑战的版本信息下
	if data.cfg then
		self.cfg = data.cfg
	end
	-- 挑战结束时间
	if data.ts then
		self.ts = data.ts
	end
	
end

function limitChallengeVo:setFlag(value)
	self.updateFlag = value
end

function limitChallengeVo:getFlag( ... )
	return self.updateFlag
end
