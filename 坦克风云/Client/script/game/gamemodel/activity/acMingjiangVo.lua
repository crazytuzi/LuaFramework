acMingjiangVo=activityVo:new()
function acMingjiangVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acMingjiangVo:updateSpecialData(data)
	if data~=nil then
		if data.value then
			self.value = data.value
		end
		if data.l then
			self.score = data.l
		end
		if data.t then
			self.lastTime = data.t
		end  
		if data.scoreLimit then
			self.scoreLimit = data.scoreLimit
		end   
		if data.cost then
			self.cost = data.cost
		end  
		if data.scoreReward then
			self.scoreReward = data.scoreReward
		end 
		if data.rankReward then
            self.rankReward=data.rankReward
        end
        if data.m then 
            self.isReceive = data.m
        end 
        if data.s then 
            self.rongyuPoint = data.s
        end 
        if data.version then
            self.version =data.version
        end 
	end
end