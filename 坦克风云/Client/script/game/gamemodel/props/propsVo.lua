propsVo={}
function propsVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function propsVo:initWithData(id,st,et)
  self.id=id
  self.startTime=st
  self.endTime=et
end