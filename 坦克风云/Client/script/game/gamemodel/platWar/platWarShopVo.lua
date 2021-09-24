platWarShopVo={}
function platWarShopVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function platWarShopVo:initWithData(id,num)
	self.id=id
	self.num=num or 0
end