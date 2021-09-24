acOldReturnVo=activityVo:new()
function acOldReturnVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.userType=nil		--是老玩家还是坚守玩家
	nc.userRewardGet=nil	--是否已经领取过坚守或者回归礼包
	nc.serverReturnNum=0	--全服回归的玩家数
	nc.serverRewardGet=0	--已经领取的全服礼包的数目
    nc.feedTime=0         --上次领取feed奖励的时间
    nc.cfg={}
	return nc
end

function acOldReturnVo:updateSpecialData(data)
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
    if(data.ft)then
        self.feedTime=tonumber(data.ft) or 0
    end
    if(self.cfg==nil)then
        self.cfg={}
    end
    if(data.minlevel)then
        self.cfg.minlevel=tonumber(data.minlevel)
    end
    if(data.totalreward)then
        self.cfg.totalreward=data.totalreward
    end
    if(data.shareReward)then
        self.cfg.shareReward=tonumber(data.shareReward)
    end
    if(data.staybehindreward)then
        self.cfg.staybehindreward=data.staybehindreward
    end
    if(data.need)then
        self.cfg.need=tonumber(data.need)
    end
    if(data.sendday)then
        self.cfg.sendday=tonumber(data.sendday)
    end
    if(data.boxclient)then
        self.cfg.box=data.boxclient
    end
end
