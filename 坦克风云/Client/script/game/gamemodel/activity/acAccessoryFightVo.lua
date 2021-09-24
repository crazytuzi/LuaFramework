acAccessoryFightVo=activityVo:new()
function acAccessoryFightVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acAccessoryFightVo:updateSpecialData(data)
end
