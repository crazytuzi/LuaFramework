acLevelingVo=activityVo:new()

function acLevelingVo:updateSpecialData(data)
    if self.reward == nil then
        self.reward = {}
    end

    if data.reward ~= nil then
    	self.reward = data.reward
    end
    
    if self.condition == nil then
        self.condition = {}
    end

    if data.con ~= nil then
        self.condition = data.con
    end
    
    if self.desVate == nil then
        self.desVate = 1
    end

    if data.desVate ~= nil then
        self.desVate = data.desVate
    end
end