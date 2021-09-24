dimensionalWarRankVo={}
function dimensionalWarRankVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function dimensionalWarRankVo:initWithData(id,name,power,point,round)
	self.id=id
	self.name=name or ""
	self.power=power or 0
	self.point=point or 0
	self.round=round or 0
end