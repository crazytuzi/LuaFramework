acContinueRechargeVo=activityVo:new()

function acContinueRechargeVo:updateSpecialData(data)
    
     --每日充值的满足条件的最小值
    if data.version then
      self.version =data.version
    end
    if self.dayCfg == nil then
      self.dayCfg = 99999
    end

    if data.dC ~= nil then
      self.dayCfg = data.dC
    end

    --黑客修改记录需要的金币数

    if self.reviseCfg == nil then
      self.reviseCfg = 99999
    end

    if data.rR ~= nil then
      self.reviseCfg = data.rR
    end
    --最终奖励
    if self.bigReward == nil then
      self.bigReward = {}
    end

    if data.bR ~= nil then
      self.bigReward = data.bR
    end
 

    --最终奖励的价值
    if self.bRValue == nil then
      self.bRValue = 0
    end

    if data.bRV ~= nil then
      self.bRValue = data.bRV
    end
    -- self.v = {400,1200,1122,700,800,900,1000}
    -- v -- v = {400,500,540,300,2,19,32}
    -- c -- 是否已领取奖励c = 0 未领取  1 已领取
end