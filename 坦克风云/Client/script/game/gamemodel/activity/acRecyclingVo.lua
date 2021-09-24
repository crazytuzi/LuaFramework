acRecyclingVo=activityVo:new()
function acRecyclingVo:new()
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acRecyclingVo:updateSpecialData( data )
	if data then

		if data.consume then--改装需要的道具
			self.consume = data.consume
		end
        if data.version then
            self.version =data.version
        end
		if data.report then
			self.tankActionData =data.report
		end
		if data.version then
			self.version = data.version
		end
		if data.rewardlist then
			self.rewardCfg = data.rewardlist
		end
        if data.l then
            self.l = data.l 
        end
        if data.f then
            self.vipHadNum = data.f
        end
    	if data.cost then
    		self.cost = data.cost
    	end
    	if data.mul then  -- 10连抽
    		self.mul = data.mul
    	end
    	if data.mulc then --9折
    		self.mulc = data.mulc
    	end
        if self.vipCfg == nil then
            self.vipCfg = {}
        end
        if data.vipCost then
            self.vipCfg = data.vipCost
        end
    	if data.t then
    		self.lastTime =data.t
    	end
	end
end