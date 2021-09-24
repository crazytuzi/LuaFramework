acJidongbuduiVo=activityVo:new()

function acJidongbuduiVo:updateSpecialData(data)
	if data.cost then
		self.cost = data.cost
	end

	if data.t then
    	self.lastTime =data.t
    end
    if data.mm ~= nil and type(data.mm)=="table" then
        for k,v in pairs(data.mm) do
            if v then
                self.turkey= v
            end
        end
    end

    if self.circleList == nil then
    	self.circleList = {}
    end
    if data.pool ~=nil then
    	self.circleList = data.pool
    end

    if self.otherReward == nil then
    	self.otherReward = {}
    end
    if data.otherReward ~=nil then
    	self.otherReward = data.otherReward
    end

    if self.tankCfg == nil then
    	self.tankCfg = {}
    end
    if data.reward ~=nil then
    	self.tankCfg = data.reward
    end

    if data.v ~=nil then
    	self.exchangeTankNum = data.v
    end

    
    if data.showNums then
        self.showNums = data.showNums
    end
    if data.limitNums then
        self.limitNums = data.limitNums
    end

end