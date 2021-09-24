bagVo={}
function bagVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function bagVo:initWithData(id,num,sortId,isUseable)
  self.id=id
 self.num=num
 self.sortId=sortId
 self.isUseable=isUseable
end