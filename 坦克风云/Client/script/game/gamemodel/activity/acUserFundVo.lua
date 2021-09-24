acUserFundVo=activityVo:new()

function acUserFundVo:updateSpecialData(data)
    -- c -- 已经领取哪一档次的充值奖励
    -- v -- 活动期间充值总额
    -- t -- 可领取哪一档的返利
    -- rt -- 上一次领取返利奖励的时间

    -- "userFund":{"type":1,"reward":[{"p":[{"index":1,"p89":1},{"p30":1,"index":2}]},{"e":[{"p6":1,"index":1},{"p3":5,"index":2}]},{"e":[{"index":1,"p5":5},{"p1":2,"index":2}]},{"p":[{"p230":1,"index":1}],"e":[{"index":2,"p2":5}]},{"p":[{"p90":1,"index":1},{"index":2,"p20":5}]}],"chargeday":7,"cost":[860,2600,6050,12100,17300],"st":"1402898520","sortId":142,"et":"1472536920","extra":[20,62,146,300,430]}

    if self.rt==nil then
        self.rt=0
    end
    if self.reward==nil then
        self.reward={}
    end
    if self.chargeday==nil then
        self.chargeday=0
    end
    if self.cost==nil then
        self.cost={}
    end
    if self.extra==nil then
        self.extra={}
    end
    if data.rt then
        self.rt=data.rt
    end
    if data.reward then
        self.reward=data.reward
    end
    if data.chargeday then
        self.chargeday=data.chargeday
    end
    if data.cost then
        self.cost=data.cost
    end
    if data.extra then
        self.extra=data.extra
    end
end


function acUserFundVo:initRefresh()
    -- self.needRefresh = true -- 排行榜结束排名后是否需要刷新数据（比如排行结束后）   这里是从前一天到第二天时需要刷新数据
end