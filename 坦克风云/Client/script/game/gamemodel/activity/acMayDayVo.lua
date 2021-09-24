acMayDayVo =activityVo:new()

function acMayDayVo:updateSpecialData(data)
    G_dayin(data)

    if self.hasBuy==nil then
    	self.hasBuy = {}
    end
    if data.b ~=nil then
    	self.hasBuy = data.b
    end

	if data.circleList then
		self.circleList =data.circleList
	    if self.token == nil then
	    	self.token = {}
	    end
	    if self.token == nil then
	    	self.token = {}
	    end
	    if data.mm ~= nil then
	    	self.token = data.mm
	    end

	    if data.shopItem ~=nil then
	    	self.shopItem = data.shopItem
	    end

	    

	    if data.version then
	        self.version = data.version
	    end

		if data.cost then
			self.singleCost =data.cost --单指针价格
		end
		if data.doubleCost then
			self.doubleCost =data.doubleCost --双指针价格
		end
		if data.value then
			self.agio =data.value  --折扣率
		end
		if data.mul then
			self.mul =data.mul --倍数
		end


	end
end