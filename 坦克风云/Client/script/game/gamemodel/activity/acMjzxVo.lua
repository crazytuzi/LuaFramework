acMjzxVo=activityVo:new()
function acMjzxVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acMjzxVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg

            if self.activeCfg.limitPoint then
                self.scoreFloor = self.activeCfg.limitPoint
            end
            if self.scoreFloor ==nil then
                self.scoreFloor = 500
            end

            if data.rankreward then--是否已经领取过排行榜奖励(记录的是名次,可以查这个值来确定领奖时的名次)
                self.rankRewardFlag=data.rankreward
            end
        end

        if data.f then
            self.firstFree = data.f
        end

        -- if data.free then --已使用的免费次数
        --     self.free=data.free
        -- end
        -- if data.fn then --免费次数
        --     self.free=data.fn
        -- end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end


        if data.n then --总积分
            self.score=data.n
        end

        if self.score == nil then
            self.score = 0
        end

        if self.activeCfg and self.activeCfg.rankpoint then
            self.scoreFloor = self.activeCfg.rankpoint
        end        

        if data.m then
            self.getedBigAward=data.m
        end

        if self.playerList ==nil then
            self.playerList ={}
        end

        if data.c then
            self.againNum = data.c
        end
        if not self.againNum then
            self.againNum = 0
        end

    end
end