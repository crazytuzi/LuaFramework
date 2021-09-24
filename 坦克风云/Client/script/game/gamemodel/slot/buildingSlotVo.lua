buildingSlotVo={}

function buildingSlotVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


--sid:队列ID bid:建筑ID st:开始时间 hid:是否发过军团求助请求
function buildingSlotVo:initWithData(bid,st,et,hid)
  self.bid=bid
  self.st=st
  self.leftTime=0
  self.et=et
  self.hid=hid
end



