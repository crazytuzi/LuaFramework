acShengdanbaozangVo=activityVo:new()

function acShengdanbaozangVo:updateSpecialData(data)
	if data.cost then
		self.cost = data.cost
	end
	if data.allCost then  -- 全部挖掘
		self.allCost = data.allCost
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

    if self.shopItem == nil then
    	self.shopItem = {}
    end
    if data.shopItem ~=nil then
    	self.shopItem = data.shopItem
    end

    if self.hasBuy==nil then
    	self.hasBuy = {}
    end
    if data.l ~=nil and data.l~=0 then
    	self.hasBuy = data.l
    end
    

    if self.showList == nil then
        self.showList ={}
    end
    if data.showlist then
        self.showList = data.showlist
    end


    if data.allowNum then
        self.allowNum = data.allowNum
    end

    if data.leftNum then
        self.leftLotteryNum = data.leftNum
    end
    -- 花钱抽奖次数
    if data.p then
        self.canClick = data.p
    end
    --免费抽奖次数
    if data.fc then
        self.freeClick = data.fc
    end

    if data.v then
        self.hadLottery = data.v
    end
    
    if data.version then
        self.version = data.version
    end


end