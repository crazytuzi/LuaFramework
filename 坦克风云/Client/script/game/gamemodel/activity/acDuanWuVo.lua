acDuanWuVo=activityVo:new()
function acDuanWuVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acDuanWuVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg = data._activeCfg
            if self.activeCfg then
                if self.activeCfg.recharge then
                    self.rechargeStallsTb = self.activeCfg.recharge
                end
                if self.activeCfg.reward then
                    self.rechargeAwardsTb = self.activeCfg.reward
                end
                if self.activeCfg.shopList then
                    self.shopListTb = self.activeCfg.shopList
                end
                if self.activeCfg.version then
                    self.version = self.activeCfg.version
                end
            end
        end
        if data.v then--累计充值金币
            self.allReNums = data.v
        end

        if data.tk then--已领奖励表
            self.hadAwardTb =data.tk
        end

        if data.tr then----商店已买道具的表
            self.buyTb = data.tr
        end

        if data.f then
            self.firstFree = data.f
        end
        if not self.firstFree then
            self.firstFree = 0
        end

        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end
        ------------------------------------------------
    end
end