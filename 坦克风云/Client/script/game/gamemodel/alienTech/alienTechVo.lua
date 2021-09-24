alienTechVo={}
function alienTechVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function alienTechVo:initWithData()

end
