acQxtwVo=activityVo:new()

function acQxtwVo:updateSpecialData(data)
    -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end

    -- 数据
    if data.t then
    	self.lastTime=data.t
    end
    if data.c then  --免费
        self.c=data.c
    end
    if data.tr then  -- 每日任务的领取标识
        self.tr=data.tr
    end
    if data.tk then  --每天的任务
        self.tk=data.tk
    end
    if data.log then
        self.log=data.log
    end
    if data.cfg then
        self.version=tonumber(data.cfg)
    end
end