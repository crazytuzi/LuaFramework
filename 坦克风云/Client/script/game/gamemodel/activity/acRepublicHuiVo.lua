acRepublicHuiVo=activityVo:new()
function acRepublicHuiVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acRepublicHuiVo:updateSpecialData(data)
    -- self.acCfg=data["reward"]           --后台返回的活动配置

    --后台返回的活动配置
    if self.acCfg==nil then
        self.acCfg={}
    end
    if data.reward then
        self.acCfg=data.pool or {}
    end
    if self.tankReward==nil then
        self.tankReward={}
    end
    if data.reward then
        self.tankReward = data.reward
    end

    if data.cost then
        self.cost = data.cost
    end
    if data.multiCost then
        self.multiCost = data.multiCost
    end
    if data.v then
        self.position = data.v
    end
    if self.hasNum==nil then
        self.hasNum={}
    end
    if data.lv then
        self.hasNum = data.lv
    end

    --上次抽奖时间的凌晨时间戳
    if self.lastTime==nil then
    	self.lastTime=0
    end
    if data.t then
    	self.lastTime=tonumber(data.t) or 0
    end
    --今日已经用掉的免费抽奖次数
    if self.hasUsedFreeNum==nil then
    	self.hasUsedFreeNum=0
    end

    if self.lastTime and G_isToday(self.lastTime)==false then
        self.hasUsedFreeNum=0
    end


end


