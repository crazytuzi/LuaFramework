acHaoshichengshuangVo = activityVo:new()

function acHaoshichengshuangVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acHaoshichengshuangVo:updateSpecialData(data)
	if data~=nil then
		-- self.acEt = self.et- 86400

	    if data.reward then                 --活动配置
	    	self.reward = data.reward
	    end

	    if self.currentState==nil then
	        self.currentState={}
	    end
	    if data.d then                      --状态信息
	        self.currentState = data.d
	    end

	    if self.rankReward==nil then
	        self.rankReward=0
	    end
	    if data.rr then
	        self.rankReward= data.rr
	    end
	end
end