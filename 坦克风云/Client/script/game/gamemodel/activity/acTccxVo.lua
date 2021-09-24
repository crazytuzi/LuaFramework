acTccxVo=activityVo:new()

function acTccxVo:updateSpecialData(data)
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
    if data.c then --免费次数是否使用
        self.useFree=data.c
    end
    if data.b then -- 购买情况
        self.b=data.b
    end
    if data.v then --代币数
        self.myPoint=data.v
    end

    if data.rd then -- 里面的东西对前台来说没用，如果没有这个字段需要先调用重置接口
        self.rd=data.rd
    end
    if data.r then -- 已经开启的牌
        self.openR=data.r or {}
    end
    if data.log then -- 记录
        self.log=data.log
    end

    if data.br then -- 大奖数量
        self.br=data.br
    end
end