rpShopVo=dailyActivityVo:new()
function rpShopVo:new(type)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.type=type
    return nc
end

function rpShopVo:canReward()
	if(rpShopVoApi:checkNoticed())then
		return false
	else
		return true
	end
end

function rpShopVo:updateData(data)
	rpShopVoApi:updatePersonalBuy(data)
end

function rpShopVo:dispose()
	rpShopVoApi:clear()
end