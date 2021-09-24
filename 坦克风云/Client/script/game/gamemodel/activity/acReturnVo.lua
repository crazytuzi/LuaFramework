acReturnVo=activityVo:new()
function acReturnVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.userType=nil		--是老玩家还是坚守玩家
	self.userRewardGet=nil	--是否已经领取过坚守或者回归礼包
	self.serverReturnNum=0	--全服回归的玩家数
	self.serverRewardGet=0	--已经领取的全服礼包的数目
	return nc
end

function acReturnVo:updateSpecialData(data)
    if(data.n)then
        self.userType=data.n
    end
    if(data.c)then
        self.userRewardGet=data.c
    end
    if(data.tnum)then
        self.serverReturnNum=data.tnum
    end
    if(data.v)then
        self.serverRewardGet=data.v
    end
end
