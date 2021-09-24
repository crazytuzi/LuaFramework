acLuckyPokerVo=activityVo:new()

function acLuckyPokerVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acLuckyPokerVo:updateSpecialData(data)
    if data then
    	if data.version then
    		self.version =data.version
    	end
    	if self.reStartTime ==nil then
			self.reStartTime =0
		end
		if data.t then
			self.lastTime =data.t
		end
    	if data.freeNum then--每日免费次数
    		self.freeNum =data.freeNum
    	end

    	if data.cost1 then
    		self.cost1 =data.cost1
    	end
    	if self.cost1 ==nil then
    		self.cost1 =999
    	end

    	if data.cost2 then
    		self.cost2 =data.cost2
    	end
    	if self.cost2==nil then
    		self.cost2 =999
    	end
    	if data.luckyReward and data.luckyReward.reward then
    		self.luckyNBReward = data.luckyReward.reward
    	end
    	if data.clientReward then
    		self.clientReward =data.clientReward
    	end
        if data.nextRequire then--翻下一张牌
            self.nextRequire = data.nextRequire
        end
        if self.awardAllTb ==nil then
            self.awardAllTb ={}
        end
        if self.curCellTimeRecord ==nil then
            self.curCellTimeRecord ={}
        end
        if self.curCellAwardTb ==nil then
            self.curCellAwardTb ={}
        end
        if self.seeRecord ==nil then
            self.seeRecord =true
        end
        if data.report then
            self.tankActionData =data.report
        end
        if self.tankActionData ==nil then
            self.tankActionData ={}
        end
        if self.curAwardTb ==nil then
            self.curAwardTb ={}
        end

        if self.isTen ==nil then
            self.isTen =0
        end

        if self.curAwardTbWithAc ==nil then
            self.curAwardTbWithAc ={}
        end
        if data.value then
            self.saleValue = data.value
        end
        if self.saleValue ==nil then
            self.saleValue =0
        end

        if data.nextRequire then
            self.nextRequire = data.nextRequire
        end
    end
end