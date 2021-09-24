acSmcjVo=activityVo:new()
function acSmcjVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acSmcjVo:updateSpecialData(data)
    if data~=nil then

        if data._activeCfg then
            if data._activeCfg.version then
                self.version = data._activeCfg.version
            end
        end
        if not self.version then
            self.version = 1
        end
        if activityCfg.smcj then
           self.activeCfg = activityCfg.smcj[self.version]
           self.scoreReward   = self.activeCfg.scoreReward
           self.needTopScore  = self.scoreReward[SizeOfTable(self.scoreReward)].needScore
           self.rechargeMin   = self.activeCfg.rechargeMin
           self.rankReward    = self.activeCfg.rankingReward
           self.dailyTaskList = self.activeCfg.dailyTaskList
           self.dailytask = self.activeCfg.dailytask
           self.rShowNum = self.activeCfg.rShowNum
           
           self.dailyGiftList = self.activeCfg.dailyGiftList
           self.dailyGiftLimitNum = self.activeCfg.dailyGiftNum
           self.giftGoldLimit = self.activeCfg.giftGold
           self.daysScore = self.activeCfg.dailytotScore
        end

        if data.f then
            self.firstFree = data.f
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end

        if data.g then
            self.curRechargeNum = data.g
        end
        if not self.curRechargeNum then--当前累计 充值
            self.curRechargeNum = 0
        end

        if data.ranklist then
            self.ranklist = data.ranklist
        end
        if not self.ranklist then
            self.ranklist = {}
        end

        if data.p then
            self.curScore = data.p 
        end
        if not self.curScore then--累计积分
            self.curScore = 0
        end

        if data.pst then
            self.scoreRewardOverTb = data.pst
        end
        if not self.scoreRewardOverTb then
            self.scoreRewardOverTb = {}
        end

        if data.tData then--每天的任务数据
            self.taskDataTb = data.tData
        end
        if not self.taskDataTb then
            self.taskDataTb = {}
        end

        if data.tst then--任务奖励领取状态
            self.tst = data.tst
        end
        if not self.tst then
            self.tst = {}
        end

        if data.dst then
            self.dayScoreTb = data.dst
        end
        if not self.dayScoreTb then
            self.dayScoreTb = {}
        end

        if data.gData then --金币奖励领取次数
            self.gData = data.gData
        end
        if not self.gData then
            self.gData = {}
        end
    end
end