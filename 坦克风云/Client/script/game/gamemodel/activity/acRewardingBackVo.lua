acRewardingBackVo=activityVo:new()
function acRewardingBackVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acRewardingBackVo:updateSpecialData(data)
    if data ~=nil then

        if data.v~=nil then
            self.rechargeGolds = data.v
        end
    	if data.reward ~= nil then
    		self.rewardCfg = data.reward
    	end
    	if data.gemsRate~=nil then --金币倍率
    		self.gemsRate = data.gemsRate
    	end
        if data.goldsRate ~=nil then --水晶倍率
        	self.goldsRate =data.goldsRate
        end
    	if data.ls ~=nil then
    		
    	end
    end
end