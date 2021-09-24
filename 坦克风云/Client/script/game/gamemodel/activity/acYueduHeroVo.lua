acYueduHeroVo=activityVo:new()
function acYueduHeroVo:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  return nc
end

function acYueduHeroVo:updateSpecialData(data)
  if data~=nil then
    if data.cost then
      self.cost=data.cost
    end
    if data.reward then
      self.reward=data.reward
    end

    if data.flag then
      self.flag=data.flag
    end

    if data.record then
      self.record=data.record
    end
    if data.t then
      self.lastTime=data.t
    end
    
  end
end
