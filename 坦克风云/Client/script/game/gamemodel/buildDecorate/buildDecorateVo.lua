-- @Author hj
-- @time 2018-09-04
-- @Description 建筑装扮的Vo

buildDecorateVo = {}

function buildDecorateVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

