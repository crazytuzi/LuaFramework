acRefitPlanVo=activityVo:new()
function acRefitPlanVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acRefitPlanVo:updateSpecialData(data)
    if data~=nil then
        if data.maxVate then
            self.maxVate = data.maxVate
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
    	if data.consume then --改装需要的道具
    		self.consume = data.consume
    	end

    	if data.reward then
    		self.bigRewardsCfg = data.reward
    	end
    	if data.ls~=nil then
    		self.rate= data.ls
    	end
    	if data.t then
    		self.lastTime =data.t
    	end
    	if data.v then
    		self.free= data.v
    	end
    end

end