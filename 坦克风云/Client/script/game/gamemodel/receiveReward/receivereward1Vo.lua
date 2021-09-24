require "luascript/script/game/gamemodel/receiveReward/receivereward1VoApi"
receivereward1Vo=dailyActivityVo:new()

function receivereward1Vo:new(type)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.type=type
    nc.flag= true
    canRewardFlag=true
    if receivereward1VoApi:checkShopOpen()==false then
        nc.flag = false
    end
    return nc
end

function receivereward1Vo:dispose()
    self.flag=true
    self.isReceive=false
    receivereward1VoApi:clear()
end

function receivereward1Vo:setReceive(flag)
    self.isReceive = flag
end

--是否要在面板上转光圈
function receivereward1Vo:canReward()
    if receivereward1VoApi:checkShopOpen()==2 and self.isReceive~=true then
        return true
    end
    return false
end

