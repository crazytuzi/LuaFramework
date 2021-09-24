acSinglesVo=activityVo:new()

function acSinglesVo:updateSpecialData(data)
	if data.cost then
		self.cost = data.cost
	end
	if data.mul then  -- 10连抽
		self.mul = data.mul
	end
	if data.mulc then --9折
		self.mulc = data.mulc
	end
	if data.t then
    	self.lastTime =data.t
    end
    if self.token == nil then
    	self.token = {}
    end
    if data.mm ~= nil then
    	self.token = data.mm
    end

    if self.goods == nil then
    	self.goods = {}
    end
    if data.goods ~=nil then
    	self.goods = data.goods
    end

    if self.circleList == nil then
    	self.circleList = {}
    end
    if data.circleList ~=nil then
    	self.circleList = data.circleList
    end

    if self.shopItem == nil then
    	self.shopItem = {}
    end
    if data.shopItem ~=nil then
    	self.shopItem = data.shopItem
    end

    if self.vipReward == nil then
    	self.vipReward = {}
    end
    if data.vipReward ~=nil then
    	self.vipReward = data.vipReward
    end

    if self.hasBuy==nil then
    	self.hasBuy = {}
    end
    if data.v ~=nil and data.v~=0 then
    	self.hasBuy = data.v
    end
    


end