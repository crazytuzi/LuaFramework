acAlienbumperweekVo=activityVo:new()

function acAlienbumperweekVo:updateSpecialData(data)
    
    if data.cfg ~= nil then
        self.version = data.cfg 
    end
    -- 资源生产加成
    if data.addrate ~= nil then
    	self.addrate = data.addrate
    end
    -- 资源上限加成
    if data.value ~= nil then
    	self.value = data.value
    end
    -- 奖励列表
    if data.reward ~= nil then
    	self.reward = data.reward
    end
    -- 充值档位
    if data.cost ~= nil then
    	self.cost = data.cost
    end
    -- 已领取的列表
    if data.r ~= nil then
    	self.r = data.r
    end
    -- icon数组
    if data.icon ~= nil then
        self.icon = data.icon
    end
end