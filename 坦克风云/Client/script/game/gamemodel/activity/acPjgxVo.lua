acPjgxVo=activityVo:new()

function acPjgxVo:updateSpecialData(data)
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
    -- 当前任务点数
    if data.n then
        self.myPoint=data.n
    end
    -- 任务点领取标志
    if data.tbox then
        self.tbox=data.tbox
    end
    -- 购买次数
    if data.bn then
        self.bn=data.bn
    end
    if data.task then
        self.task=data.task
    end

end