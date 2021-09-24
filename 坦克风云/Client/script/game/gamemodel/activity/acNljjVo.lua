acNljjVo=activityVo:new()

function acNljjVo:updateSpecialData(data)
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
    if data.r then  --排行榜奖励已领取
        self.r=data.r
    end
    if data.p then -- 排行积分
        self.p=data.p
    end
    if data.v then
        self.v=data.v
    end

    if data.log then
        self.log=data.log
    end
    if data.data and data.data.ranklist then
        self.ranklist=data.data.ranklist
        self.lastTs=data.ts
    end
end