acHalloween2018Vo=activityVo:new()
function acHalloween2018Vo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acHalloween2018Vo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg

            if self.activeCfg.extraReward then
            	self.extraReward = self.activeCfg.extraReward
            end

            if self.activeCfg.pumpkinFullNum then
	        	self.topScore = self.activeCfg.pumpkinFullNum
	        end
	        if self.activeCfg.reward then
	        	self.reward = self.activeCfg.reward
	        end
	        if self.activeCfg.rechargeItem then
	        	self.clockItemId = self.activeCfg.rechargeItem
	        end
	        if self.activeCfg.flicker then
	        	self.flickerTb = self.activeCfg.flicker
	        end
	        if self.activeCfg.recharge then
	        	self.topRecharge = self.activeCfg.recharge
	        end
	        if self.activeCfg.levelLimit then
	        	self.levelLimit = self.activeCfg.levelLimit
	        end
            if self.activeCfg.version then
                self.version = self.activeCfg.version
            end
        end

        if data.f then
            self.free = data.f
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end
        if data.p then --总糖果数
            self.score=data.p
        end
        if not self.score then
        	self.score = 0
        end
        if data.c then
        	self.curNum = data.c
        end

        if data.tk then
        	self.getedAwardBoxTb = data.tk
        end

        if data.v then
        	self.curRecharge = data.v
        end
    end
end