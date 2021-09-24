acHoldGroundVo=activityVo:new()

function acHoldGroundVo:updateSpecialData(data)
    --奖励配置
    if self.acCfg==nil then
        self.acCfg={awardCfg={},flick={}}
    end
    if data.reward then
        self.acCfg={awardCfg={},flick={}}
        if data.reward.awardCfg then
            for k,v in pairs(data.reward.awardCfg) do
                local item=FormatItem(v,nil,true) or {}
                table.insert(self.acCfg.awardCfg,item)
            end
        end
        if data.reward.flick then
            self.acCfg.flick=FormatItem(data.reward.flick) or {}
        end
    end
    
    if data.version then
        self.version = data.version
    end
    --领奖次数
    if self.rewardNum==nil then
        self.rewardNum=0
    end
    if data.v then
        self.rewardNum=data.v or 0
    end

    --上次领奖时间
    if self.lastTime==nil then
        self.lastTime=0
    end
    if data.t then
        self.lastTime=data.t or 0
    end

end
