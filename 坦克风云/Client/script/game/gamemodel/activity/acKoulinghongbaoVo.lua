acKoulinghongbaoVo=activityVo:new()
function acKoulinghongbaoVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    self.num=0
	return nc
end

function acKoulinghongbaoVo:updateSpecialData(data)
    if data.num then
        self.num=tonumber(data.num) or 0
    end
end
