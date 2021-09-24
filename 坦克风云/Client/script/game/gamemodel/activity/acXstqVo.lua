acXstqVo=activityVo:new()
function acXstqVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acXstqVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg

            if self.activeCfg.version then
                self.version = self.activeCfg.version
            end
            if not self.version then
                self.version = 1
            end
        end

        if data.f then
            self.firstFree = data.f
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end

        if data.bn then
            self.curData = data.bn
        end
        -- "t1":[  -- 档位
        --         0,  -- 充值次数
        --         2  -- 领取次数
        --     ],
        if not self.curData then
            self.curData = {}
        end

        if self.activeCfg then
            if self.activeCfg.levelGroup then
                self.levelGroup = self.activeCfg.levelGroup
            end
            if self.activeCfg.rechargeReward then
                self.rewardTb = self.activeCfg.rechargeReward
            end
        end
    end
end