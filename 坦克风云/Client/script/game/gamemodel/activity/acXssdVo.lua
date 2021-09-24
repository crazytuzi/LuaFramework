acXssdVo=activityVo:new()

function acXssdVo:updateSpecialData(data)
   -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end
    if data.b then -- 购买情况
        self.b=data.b
    end
    if data.t then
        self.lastTime=data.t
    end
end