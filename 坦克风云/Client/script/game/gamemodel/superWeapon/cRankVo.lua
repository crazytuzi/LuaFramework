cRankVo={}
function cRankVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function cRankVo:initWithData(id,name,level,rank,value)
	self.id=id
	self.name=name
	self.level=level
	self.rank=rank
    self.value=value
end