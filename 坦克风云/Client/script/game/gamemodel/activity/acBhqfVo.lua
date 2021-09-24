acBhqfVo=activityVo:new()

function acBhqfVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
            --和谐版
            if self.activeCfg.hxcfg and self.activeCfg.hxcfg.reward then
                self.hxReward = self.activeCfg.hxcfg.reward
            end
        end
        if data.t then -- 上一次抽奖的凌晨时间戳
            self.lastTime =data.t
        end
        if data.rd then -- 领取任务奖励 {1,3,4}
            self.rd=data.rd
        end
        if data.words then -- 点燃获得字符
            self.words=data.words
        end
        if data.log then -- 奖励日志
            self.log=data.log
        end
    end
    
end
