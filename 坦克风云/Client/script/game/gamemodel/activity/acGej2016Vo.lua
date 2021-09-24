acGej2016Vo=activityVo:new()

function acGej2016Vo:updateSpecialData(data)
    -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end

    -- 数据
    if data.t then
    	self.lastTime=data.t
    end
    if data.v then  -- 爱心值
        self.v=data.v
    end
    if data.c then  --每天礼包领取标识＝1已领取
        self.c=data.c
    end
    if data.tr then  -- 每日任务的领取标识
        self.tr=data.tr
    end
    if data.tk then  --每天的任务
        self.tk=data.tk
    end
    if data.b then  --商店购买记录 有限制的有无限制的没有
        self.b=data.b
    end
end