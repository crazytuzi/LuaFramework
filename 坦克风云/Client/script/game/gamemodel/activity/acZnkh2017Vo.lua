acZnkh2017Vo=activityVo:new()

function acZnkh2017Vo:updateSpecialData(data)
    -- 配置
    if data._activeCfg then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
    end

    -- 数据
    if data.t then -- 当天的临晨时间戳跨天清除数据
    	self.lastTime=data.t
    end
    if data.t then -- 领取头像奖励 标志
        self.v=data.v 
    end
    if data.day then -- 每天任务
        self.day=data.day
    end

    -- 当前任务点数
    if data.n then
        self.myPoint=data.n
    end

    -- 任务点领取标志
    if data.tbox then
        self.tbox=data.tbox
    end

    if data.ln then -- 累计抽奖次数
        self.ln=data.ln
    end
    if data.gems then -- 累计消费金币数量
        self.gems=data.gems
    end
end