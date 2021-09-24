platWarRankVo={}
function platWarRankVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function platWarRankVo:initWithData(id,name,platId,server,rank,value)
	self.id=id
	self.name=name
	self.platId=platId
	self.server=server
	self.rank=rank
	self.value=value
end