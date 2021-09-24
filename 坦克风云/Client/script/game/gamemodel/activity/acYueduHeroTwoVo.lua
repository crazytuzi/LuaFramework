acYueduHeroTwoVo=activityVo:new()
function acYueduHeroTwoVo:new()
  local nc={}
  setmetatable(nc,self)
  self.__index=self
  return nc
end
--新增 r记录刷新次数
function acYueduHeroTwoVo:updateSpecialData(data)
  if data.flag then
      self.flag=data.flag
  end

  if data.t then
      self.lastTime=data.t
  end
  if data.record then
    self.record=data.record
  end
  
  -- if not self.record then
  --   self.record= {}
  -- end

  if data.r then
    self.isRef = data.r
  end

  if not self.isRef then--默认为0 未刷新
    self.isRef = {[1]=0,[2]=0}
  end


  if data.v then
      self.curLibry = data.v
  end
  if not self.curLibry then
      self.curLibry = 0
  end

  if data.rd then
      self.refKey = data.rd
  end



  if data and data._activeCfg then
    if data._activeCfg.version then
      self.version=data._activeCfg.version
    end
    if data._activeCfg.cost then
      self.cost=data._activeCfg.cost
    end
    if data._activeCfg.reward then
      self.allReward = data._activeCfg.reward
    end
    
    if data._activeCfg.reward then
      self.reward = {}
      if self.refKey and SizeOfTable(self.refKey) > 0 then
        self.reward[1]=data._activeCfg.reward[1][self.refKey[1]]
        self.reward[2]=data._activeCfg.reward[2][self.refKey[2]]
      else
        self.refKey = {}
        self.reward[1]=data._activeCfg.reward[1][1]
        self.reward[2]=data._activeCfg.reward[2][1]
      end
    end
    if not self.reward then
        self.reward = {}
    end
    self.refresh={1,1}
    if data._activeCfg.refresh then --刷新次数
      self.refresh=data._activeCfg.refresh
    end
  end
 
end
