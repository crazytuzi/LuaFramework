acQuanmintankeVo=activityVo:new()

function acQuanmintankeVo:updateSpecialData(data) 
  if data then
    if data.cost1 then
      self.cost1=data.cost1 --普通单价
    end
    if data.cost3 then
      self.cost3=data.cost3 --锁定单价
    end
    if data.rate then
      self.rate=data.rate
    end
    if data.t then
      self.lastTime=data.t
    end
    if self.lastResult == nil then
      self.lastResult = {1,1,1}
    end

    if data.report ~= nil then
      self.lastResult = data.report
    end
    if data.my2 then
      self.tankTb=data.my2
    end
    if data.tank then
      self.rewardTank=data.tank
    end
    if data.vipdis then
      self.Vipdiscoun=data.vipdis
    end
    if data.mulc then
      self.mulc=data.mulc
    end
    -- 新版需添加
    if data.mustMode then
      self.mustMode = data.mustMode
    end
    if data.mustReward1 then
      self.mustReward1 = data.mustReward1
    end
    if data.mustReward2 then
      self.mustReward2 = data.mustReward2
    end
  end
end