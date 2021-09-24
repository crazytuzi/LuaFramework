acBtzxVo=activityVo:new()

function acBtzxVo:updateSpecialData(data)
    -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end
    if data.data and data.data.myrank then
        self.myrank=data.data.myrank
        self.lastTs=data.ts+30
    end
    if data.data and data.data.myrb then
        self.myrb=data.data.myrb
    end
    if data.data and data.data.ranklist then
        self.ranklist=data.data.ranklist
    end
    if data.c then
        self.c=data.c 
    end
end