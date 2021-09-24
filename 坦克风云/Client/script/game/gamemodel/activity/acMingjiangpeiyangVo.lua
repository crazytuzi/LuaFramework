acMingjiangpeiyangVo = activityVo:new()

function acMingjiangpeiyangVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    nc.cost1=0
    nc.cost2=0
    nc.pointTimes=0
    nc.maxPoint=0
    nc.freeNum=0
    nc.usedFree=0
    nc.pointTb={0,0,0,0}
    nc.multiplierFlag=1
    nc.clientReward={}
    nc.version=1

	return nc
end

function acMingjiangpeiyangVo:updateSpecialData(data)
	if data~=nil then
        if data.cost1 then
            self.onceCost=data.cost1 --一次培养的金币消耗
        end
        if data.cost2 then
            self.tenCost=data.cost2 --十次培养的金币消耗
        end
        if data.pointTimes then
            self.pointTimes=data.pointTimes --积分翻倍倍数
        end
        if data.maxPoint then
            self.maxPoint=data.maxPoint --每种类型的最大积分
        end
        if data.freeNum then
            self.freeNum=data.freeNum --每日免费抽奖的次数
        end
        if data.clientReward then
            self.clientReward=data.clientReward --培养完成后的奖励
        end
        if data.f then
            self.usedFree=data.f --每日已使用的免费次数
        end
        if data.s then
            self.pointTb=data.s --4项培养的积分数据
        end
        if data.d then
            self.multiplierFlag=data.d --积分翻倍标记 1：翻倍 0：翻倍期已过
        end
        if data.version then
            self.version=data.version --活动配置版本
        end
    	if data.t then
    		self.lastTime=data.t --抽奖的时间
    	end
        if data.mustGetHero then --积分满时必得的将领
            self.mustGetHero=data.mustGetHero
        end
    end
end
