dimensionalWarPointDetailVo={}
function dimensionalWarPointDetailVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function dimensionalWarPointDetailVo:initWithData(type,time,message,color,round)
	self.type=type
	self.time=time or 0
	self.message=message or ""
	self.color=color or G_ColorGreen
	self.round=round
end