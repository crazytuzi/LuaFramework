acJsysVo=activityVo:new()

function acJsysVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acJsysVo:updateSpecialData(data)

    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if data.free then --已使用的免费次数
            self.free=data.free
        end
        if data.fn then --免费次数
            self.free=data.fn
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end

        if data.n then --总积分
            self.score=data.n
        end
        if self.score ==nil then
            self.score = 0
        end

        if data.c then -- 当前总档位范围内的积分（三档）
            self.curScore =data.c
        end
        if self.curScore == nil then
            self.curScore = 0
        end

        if self.activeCfg and self.activeCfg.rankpoint then
            self.scoreFloor = self.activeCfg.rankpoint
        end
        if self.scoreFloor ==nil then
            self.scoreFloor = 10000
        end

        if self.pointsTb ==nil then
            self.pointsTb = {}
        end

        if data.m then
            self.getedBigAward=data.m
        end

        if self.playerList ==nil then
            self.playerList ={}
        end

        if data.r1 then--是否已经领取过排行榜奖励(记录的是名次,可以查这个值来确定领奖时的名次)
            self.rankRewardFlag=data.r1
        end
        if data.score then
            self.score=data.score
        end
    end
end