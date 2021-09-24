acContinueRechargeNewGuidVo=activityVo:new()

function acContinueRechargeNewGuidVo:updateSpecialData(data)
    
     --每日充值的满足条件的最小值
    if data.version then
        self.version =data.version
    end
    if self.dayCfg == nil then
        self.dayCfg = 99999
    end

    if self.needDay == nil then
        self.needDay = 999
    end

    if self.lastDay == nil then
        self.allDay = 7
    end

    if self.final == nil then
        self.final = {}
    end

    if self.reward == nil then
        self.reward = {}
    end

    if self.bigAwardHad == nil then
        self.bigAwardHad = 0
    end

    if data.c then
      self.bigAwardHad = data.c
    end

    if data.v then
      self.rechargedTb = data.v----充值数据 如果不是tab就是没充值过 如果充值过是就是一个tab={0,11,0,0,0,0} 有几天就是几条数据。
    end

    if data.r then
      self.getAwardTb = data.r--是7天领奖信息，
    end

    if data._activeCfg then
        if data._activeCfg.version then
            self.version = data._activeCfg.version
        end

        if data._activeCfg.reward and data._activeCfg.reward.continue and data._activeCfg.reward.continue[1].needMoney then
            self.dayCfg = data._activeCfg.reward.continue[1].needMoney
        end

        if data._activeCfg.needDay then
            self.needDay = data._activeCfg.needDay
        end

        if data._activeCfg.lastDay then
            self.allDay = data._activeCfg.lastDay
        end

        if data._activeCfg.reward and data._activeCfg.reward.final then
            self.final = data._activeCfg.reward.final
        end

        if data._activeCfg.reward and data._activeCfg.reward.continue then
            self.continue = data._activeCfg.reward.continue
        end        
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