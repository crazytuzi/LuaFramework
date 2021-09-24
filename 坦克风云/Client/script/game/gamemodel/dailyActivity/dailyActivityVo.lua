--日常活动的数据vo
dailyActivityVo={}

function dailyActivityVo:new(type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.type=type
	return nc
end

function dailyActivityVo:updateData(data)
	-- body
end

--是否要在面板上转光圈
function dailyActivityVo:canReward()
	return false
end

--目前活动是否激活
function dailyActivityVo:checkActive()
	return false
end