acYuebingshenchaVo = activityVo:new()
function acYuebingshenchaVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acYuebingshenchaVo:updateSpecialData(data)
	if data~=nil then
		if data.consume then --改装需要的道具
    		self.consume = data.consume
    	end

    	if data.reward then
    		self.reward=data.reward  --奖励的四种道具
    	end

    	if data.cost then
    		self.cost = data.cost
    	end

    	if data.mulCost then
    		self.mulCost = data.mulCost
    	end

        if data.p then
            self.nowP = data.p
        end

        if data.t then
            self.lastTime=data.t
        end

        if data.version then
            self.version=data.version
        end

        if data.report then
            self.tankActionData =data.report
        end

        if data.vipDiscount then
            self.vipDiscount = data.vipDiscount
        end
	end
end