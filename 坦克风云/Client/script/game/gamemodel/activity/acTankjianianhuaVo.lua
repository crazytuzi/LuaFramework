acTankjianianhuaVo=activityVo:new()

function acTankjianianhuaVo:updateSpecialData(data) 
    
    if self.free == nil then
      self.free = 0 -- 每日免费抽奖次数
    end

    if data.free ~= nil then
      self.free = data.free
    end

    if self.cost == nil then
      self.cost = 99999 -- 非免费抽奖每次需要的金币
    end

    if data.cost ~= nil then
      self.cost = data.cost
    end
    
    if self.mul == nil then
      self.mul = 0 -- 模式倍数
    end
    
    if data.mul ~= nil then
      self.mul = data.mul
    end

    if self.mulCost == nil then
      self.mulCost = 99999 -- 模式倍数下花费的金币是self.mulCost * self.cost
    end
    
    if data.mulCost ~= nil then
      self.mulCost = data.mulCost
    end
    
    if data.version then
        self.version = data.version
    end

    if data.showicon then
      self.showIcon = data.showicon
    end

    if data.rewardlist then
      self.rewardList = data.rewardlist
    end

    --万能icon
    if data.niubiicon then
      self.specialIcon = data.niubiicon
    end
    
    if data.t then
      self.lastTime=data.t
    end
end
