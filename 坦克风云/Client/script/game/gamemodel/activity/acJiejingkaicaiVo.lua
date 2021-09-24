acJiejingkaicaiVo=activityVo:new()

function acJiejingkaicaiVo:updateSpecialData(data)
	if data then
		if data.cost1 then
			self.cost = data.cost1
		end
		if data.cost2 then
			self.mulCost = data.cost2
		end
		if data.rewardlist then
			self.rewardlist=data.rewardlist
		end
		if data.t then
            self.lastTime=data.t
        end
        if data.r then
	    	self.dajiang = data.r
	    end
            
	end
end 