acXingyunpindianVo=activityVo:new()
function acXingyunpindianVo:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  return nc
end

function acXingyunpindianVo:updateSpecialData(data)
  if data~=nil then
    if data.pool then
        self.acCfg=data.pool
    end
    if data.v then
        self.position = data.v
    end
    if data.n then
      self.alreadyCost = data.n
    end
    if data.c then
      self.alreadyUse = data.c
    end
    if data.recharge then
      self.recharge=data.recharge
    end
    if data.multiCost then
      self.multiCost=data.multiCost
    end
  end
end