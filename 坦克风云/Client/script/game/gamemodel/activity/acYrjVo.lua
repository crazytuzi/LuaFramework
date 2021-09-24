acYrjVo=activityVo:new()
function acYrjVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acYrjVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg = data._activeCfg
            if self.activeCfg then

                self.exchangeTb = self.activeCfg.exchange or nil

                self.rechargeNeed = self.activeCfg.recharge or nil
            end
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
        if data.rd then
            self.exchangedTb = data.rd
        end
        if not self.exchangedTb then--已兑换的表
            self.exchangedTb = {}
        end

        if data.xc then--当前积分（小丑）
            self.curScoreNum = data.xc
        end
        if not self.curScoreNum then
            self.curScoreNum = 0
        end

        if data.needc then
            self.needRechargeNum = data.needc
        end
        if not self.needRechargeNum then
            self.needRechargeNum = self.rechargeNeed
        end
        
        if not self.hasNewRechargeTip then
            self.hasNewRechargeTip = false
        end
    end
end