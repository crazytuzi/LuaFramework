acBuyrewardVo=activityVo:new()

function acBuyrewardVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acBuyrewardVo:updateSpecialData(data)
    if data then
    	if data.t then
	      self.lastTime=data.t
	    end
    	if data.cost1 then
    		self.cost1=data.cost1
    	end
    	if data.cost2 then
    		self.cost2=data.cost2
    	end
    	if data.buyProp1 then
    		self.buyProp1=data.buyProp1
    	end
    	if data.buyProp2 then
    		self.buyProp2=data.buyProp2
    	end
    	if data.flickReward then -- 大奖，需要加闪框(对应奖池的index)
    		self.flickReward=data.flickReward
    	end
    	if data.clientReward then -- 展示奖池
    		if data.clientReward.showList then
    			self.showList=data.clientReward.showList
    		end
    	end
        if data.bgImg then
            self.bgImg=data.bgImg
        end
        if data.acIcon then
            self.acIcon=data.acIcon
        end
        if data.f then
            self.f=data.f
        end
        if data.nameType then
            self.nameType=data.nameType
        end

    end
end