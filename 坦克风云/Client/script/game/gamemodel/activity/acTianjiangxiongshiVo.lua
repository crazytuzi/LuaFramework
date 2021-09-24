acTianjiangxiongshiVo=activityVo:new()

function acTianjiangxiongshiVo:updateSpecialData(data) 
  if data then
    if data.cost1 then
      self.cost1=data.cost1 --普通单价
    end
    if data.cost2 then
      self.cost2=data.cost2 --普通十倍
    end
    if data.cost3 then
      self.cost3=data.cost3 --锁定单价

    end
    if data.cost4 then
      self.cost4=data.cost4  --锁定十倍
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
  end
end