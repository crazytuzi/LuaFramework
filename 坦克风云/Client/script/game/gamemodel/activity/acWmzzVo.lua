acWmzzVo=activityVo:new()

function acWmzzVo:updateSpecialData(data)
   -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end
    -- 数据
    if data.t then
        self.lastTime=data.t
    end
    if data.f then
        self.fragT=data.f
    end
    if data.fn then
        self.c=data.fn
    end
end