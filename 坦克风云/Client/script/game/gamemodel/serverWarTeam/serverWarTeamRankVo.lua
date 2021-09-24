serverWarTeamRankVo={}
function serverWarTeamRankVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function serverWarTeamRankVo:initWithData(id,name,server,rank,value)
	self.id=id
	self.name=name or ""
	self.server=server or ""
	self.rank=tonumber(rank)
	self.value=tonumber(value) or 0
end