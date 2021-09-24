--@Author hj
--@Description 天天基金活动数据模型

dailyTtjjVo = dailyActivityVo:new()

function dailyTtjjVo:new(type)
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  nc.type=type
  return nc
end

function dailyTtjjVo:canReward()
	if dailyTtjjVoApi:judgeAllLimit() == true then
		return true
	else
		return false
	end
end

