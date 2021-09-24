acZnkh19Vo = activityVo:new()
function acZnkh19Vo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acZnkh19Vo:updateSpecialData(data)
    if data._activeCfg then
        self.cfg = data._activeCfg
        --和谐版
        if self.cfg.hxcfg and self.cfg.hxcfg.reward then
            self.hxReward = self.cfg.hxcfg.reward
        end
    end
    if data.gtm then
        self.isDivided = data.gtm or 0 --是否已瓜分奖池
    end
    if data.acp then
        self.numerals = data.acp or {} --拥有的数字
    end
    if data.gtb then
        self.recharge = data.gtb or {0, 0} --{充值金额，礼包领取次数}
    end
    if data.ecl then
        self.exrecords = data.ecl or {} --兑换记录
    end
    if data.f then
        self.lottery_at = data.f or 0 --抽奖时间戳
    end
    if data.sl then --赠送记录
        self.giveRecords = data.sl
    end
end
