acArmorEliteVo=activityVo:new()

function acArmorEliteVo:updateSpecialData(data)
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
    if data.log then -- 记录
        self.log=data.log
    end
    if data.bn then -- 累计都买次数
        self.bn=data.bn
    end
end