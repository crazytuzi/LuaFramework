serverWarPointRankVo={}
function serverWarPointRankVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function serverWarPointRankVo:initWithData(id,name,server,rank,value)
	self.id=id
	self.name=name or ""
	self.server=server or ""
	self.rank=rank
	self.value=value or 0
end