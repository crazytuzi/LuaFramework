acSwchallengeactiveVo=activityVo:new()
function acSwchallengeactiveVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acSwchallengeactiveVo:updateSpecialData(data)
end
