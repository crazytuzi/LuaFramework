acOpenyearVo=activityVo:new()

function acOpenyearVo:updateSpecialData(data)
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
    if data.c then
        self.c=data.c --  》＝1是当天领取免费的福包的标识
    end
    if data.v then
        self.v=data.v -- 充值金币的数量
    end
    if data.f then
        self.f=data.f -- 福气值
    end
    if data.log then
        self.log=data.log
    end
    if data.dt then -- 每天做的任务
        self.dt=data.dt
    end
    if data.df then --领取任务奖励的key
        self.df=data.df
    end
    if data.rf then --领取充值奖励的key
        self.rf=data.rf
    end
    if data.p then -- 福包数量
        self.p=data.p
    end
    if data.ff then -- 领取福气值的记录
        self.ff=data.ff
    end
    if data.log then
        self.log=data.log
    end


end