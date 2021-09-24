acDlbzVo=activityVo:new()
function acDlbzVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acDlbzVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if self.activeCfg then
            
            if self.activeCfg.t then --上次抽奖的时间，用于跨天重置免费次数
                self.lastTime=self.activeCfg.t
            end

            if self.activeCfg.openLv then
                self.openLv = self.activeCfg.openLv
            end

            if self.activeCfg.cost then
                self.costTb = self.activeCfg.cost
            end

            if self.activeCfg.bigGiftNeed then
                self.bigGiftNeed = self.activeCfg.bigGiftNeed
            end

            if self.activeCfg.roundNum then
                self.roundNum = self.activeCfg.roundNum
            end

            if self.activeCfg.reward then
                self.poolRewardTb = self.activeCfg.reward
            end

            if self.activeCfg.extraReward then
                self.extraRewardTb = self.activeCfg.extraReward
            end
        end

        -- if data.f then
        --     self.firstFree = data.f
        -- end

        if data.c then--总抽奖次数
            self.rCount = data.c
        end
        if not self.rCount then
            self.rCount = 0
        end

        if data.rd then--已抽到奖励 id序号
            self.getRewardTb = data.rd
        end
        if not self.getRewardTb then
            self.getRewardTb = {}
        end

        if data.lun then
            self.lc = data.lun
        end
        if not self.lc then
            self.lc = 0
        end

        if data.rate then -- 当前抽奖得到的奖励id,
            self.rate = data.rate
        end
        
        if data.n then--当前这轮抽奖的 已抽次数
            self.curReCount = data.n
        end
        if not self.curReCount then
            self.curReCount = 0
        end
    end
end