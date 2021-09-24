acGrabRedVo=activityVo:new()

function acGrabRedVo:updateSpecialData(data)
	-- v 代币数
    if self.grabed == nil then
    	self.grabed = {}
    end
    
    if data.t ~= nil and type(data.t)=="table" then
    	self.grabed = data.t
    end

    -- 初始值
    if self.conditiongems == nil then
    	self.conditiongems = 0
    end

    if data.conditiongems ~= nil then
    	self.conditiongems = data.conditiongems
    end

	--  购买宝箱需要的金币
	if self.cost == nil then
		self.cost = 9999999
	end

	if data.cost ~= nil then
		self.cost = data.cost
	end

    --  使用代币的比例
    if self.value == nil then
    	self.value = 0
    end

	if data.value ~= nil then
		self.value = data.value
	end
    
    --  抢代币的最大个数
    if self.maxcount == nil then
    	self.maxcount = 0
    end

	if data.maxcount ~= nil then
		self.maxcount = data.maxcount
	end

    if data.version then
        self.version =data.version
    end
end