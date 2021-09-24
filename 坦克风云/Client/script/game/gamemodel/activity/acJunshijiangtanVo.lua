acJunshijiangtanVo=activityVo:new()
function acJunshijiangtanVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acJunshijiangtanVo:updateSpecialData(data) 
	if data~=nil then
    	if data.t then
    		self.score = data.t
    	end
    	if data.v then
    		self.lastTime = data.v
    	end 
        if data.m then 
            self.isReceive = data.m
        end 
        if data.scoreLimit then
            self.scoreLimit=data.scoreLimit
        end
        if data.rankReward then
            self.rankReward=data.rankReward
        end
        if data.rewardlist then
            self.rewardlist=data.rewardlist
        end
        if data.gemcost then
            self.gemcost=data.gemcost
        end
        if data.version then
            self.version =data.version
        end
    end
end