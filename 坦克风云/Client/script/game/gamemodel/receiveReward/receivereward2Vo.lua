require "luascript/script/game/gamemodel/receiveReward/receivereward2VoApi"
receivereward2Vo=dailyActivityVo:new()

function receivereward2Vo:new(type)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.type=type
    nc.flag= true
    canRewardFlag=true
    if receivereward2VoApi:checkShopOpen()==false then
    	nc.flag = false
    end
    return nc
end

function receivereward2Vo:dispose()
    self.flag = true
    self.isReceive=false
	receivereward2VoApi:clear()
end

function receivereward2Vo:setReceive(flag)
	self.isReceive = flag
end

function receivereward2Vo:canReward()
    if receivereward2VoApi:checkShopOpen()==2 and self.isReceive~=true then
        return true
    end
    return false
end

