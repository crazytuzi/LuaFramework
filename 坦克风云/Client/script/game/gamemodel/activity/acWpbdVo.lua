acWpbdVo=activityVo:new()
function acWpbdVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acWpbdVo:updateSpecialData(data)
    if data~=nil then

        if data.r then
            self.rewardTb = data.r
            self.isFirstReward = nil
        end

        if activityCfg.wpbdCfg then
            self.activeCfgSelf = activityCfg.wpbdCfg[acWpbdVoApi:getVersion()]
            if self.activeCfgSelf then
                if self.activeCfgSelf.exchange then
                    self.canExchangeSelfTankTb = self.activeCfgSelf.exchange
                end
                if self.activeCfgSelf.shoplist then
                    self.factorTb = self.activeCfgSelf.shoplist
                end

                if not self.rewardTb then
                    self.rewardTb = self.activeCfgSelf.reward.firstpool
                    self.isFirstReward = true
                end
                if not self.poolRewardTb then
                    self.poolRewardTb = self.activeCfgSelf.reward
                end
            end
        end
        if data._activeCfg then
            self.activeCfg = data._activeCfg
            if self.activeCfg.rateShow then
                self.rateShow = self.activeCfg.rateShow
            end

            if self.activeCfg.score then
                self.awardScoreTb = self.activeCfg.score
            end

            if self.activeCfg.lockCost then
                self.lockCostTb = self.activeCfg.lockCost
            end

            if self.activeCfg.cost then
                self.costTb = self.activeCfg.cost
            end
        end
        -- if data.tk then--已领奖励表
        --     self.hadAwardTb =data.tk
        -- end
        if data.v then--当前得到的所有积分，
            self.allScore = data.v
        end
        if data.c then--抽奖次数
            self.costNum = data.c
        end
        if data.b then--商店已兑换的表
            self.exchangeTb = data.b
        end
        if not self.exchangeTb then
            self.exchangeTb = {}
        end
        if data.e then--自身车库已兑换的表
            self.exchangedSelfTankTb = data.e
        end
        if not self.exchangedSelfTankTb then
            self.exchangedSelfTankTb = {}
        end
        if data.f then
            self.firstFree = data.f
        end
        if not self.firstFree then--0 有免费 1 没有
            self.firstFree = 1
        end

        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end

        -- 自行修改
        if not self.multiNum then -- (倍率选择，两种 1，2)  默认 为 1 免费 为1
            self.multiNum = 1
        end
        ------------------------------------------------
    end
end