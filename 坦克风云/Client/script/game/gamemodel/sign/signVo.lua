signVo={}
function signVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function signVo:initWithData(id,award)
	self.id=id
	self.award=award
end