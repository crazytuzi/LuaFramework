dimensionalWarShopVo={}
function dimensionalWarShopVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function dimensionalWarShopVo:initWithData(id,num)
	self.id=id
	self.num=num or 0
end