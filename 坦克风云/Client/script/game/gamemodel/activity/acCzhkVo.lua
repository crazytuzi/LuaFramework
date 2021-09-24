acCzhkVo=activityVo:new()
function acCzhkVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acCzhkVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg

            if self.activeCfg.reward then
                local reward = self.activeCfg.reward
                if reward.totalR then
                    self.totalR = reward.totalR
                end
                if reward.dailyR then
                    self.dailyR = reward.dailyR
                end
            end
        end

        if data.f then
            self.firstFree = data.f
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end

        if data.tr then
            self.rechargeDaysTb = data.tr
        end
        if not self.rechargeDaysTb then--累计充值天数
            self.rechargeDaysTb = {}
        end

        if data.d then
            self.curDayRecharge = data.d
        end
        if not self.curDayRecharge then--当天的充值数
            self.curDayRecharge = 0
        end
    end
end