useItemSlotVo={}

function useItemSlotVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


--sid:队列ID id:物品ID st:开始使用时间
function useItemSlotVo:initWithData(id,st,et)
    
  self.id=id
  self.st=st
  self.et=et

end



