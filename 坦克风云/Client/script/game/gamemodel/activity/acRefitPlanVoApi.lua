acRefitPlanVoApi={}

function acRefitPlanVoApi:getAcVo()
	return activityVoApi:getActivityVo("refitPlanT99")
end

function acRefitPlanVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acRefitPlanVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acRefitPlanVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acRefitPlanVoApi:getBigRewardsCfg()
	local vo=self:getAcVo()
	if vo and vo.bigRewardsCfg then
		return vo.bigRewardsCfg
	end
	return {}
end

function acRefitPlanVoApi:getBigrewardsRate()
	local vo=self:getAcVo()
	if vo and vo.rate then
		return vo.rate
	end
	return 1
end

function acRefitPlanVoApi:getLotteryOnceCost( ... )
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end

function acRefitPlanVoApi:getLotteryTenCost( ... )
	local vo=self:getAcVo()
	if vo and vo.cost and vo.mul and vo.mulc then
		return vo.cost*vo.mul*(vo.mulc/vo.mul)
	end
	return 0
end

function acRefitPlanVoApi:getRefitTankNeedCfg( ... )
	local vo=self:getAcVo()
	if vo and vo.consume then
		return vo.consume
	end
	return {}
end

function acRefitPlanVoApi:getTankID( ... )
	local vo=self:getAcVo()
	local aid
	local tankID
	if vo and vo.consume then
		for k,v in pairs(vo.consume) do
			aid=k
		end
	end
	if aid then
		local arr = Split(aid,"a")
		tankID =arr[2]
	end
	return aid,tonumber(tankID)
end
function acRefitPlanVoApi:getRefitNeedTankIDAndNum( ... )
	local aid,tankID = acRefitPlanVoApi:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local needAid
	local needTankID
	local upgradeShipConsume = {}
	if aid and consume and consume[aid] and consume[aid]["upgradeShipConsume"] then
		upgradeShipConsume=consume[aid]["upgradeShipConsume"]
		needAid = upgradeShipConsume[1]
		needNum = upgradeShipConsume[2]
	end
	if needAid then
		local arr = Split(needAid,"a")
		needTankID =arr[2]
	end
	return tonumber(needTankID),tonumber(needNum)
end

function acRefitPlanVoApi:getUpgradedTankResources()
	local aid,tankID = acRefitPlanVoApi:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local r1,r2,r3,r4,reUpgradedMoney=0,0,0,0,0
	print(consume,aid)
	if consume and aid then
		print("upgradeMetalConsume",consume[aid],consume[aid]["upgradeMetalConsume"])
		r1=tonumber(consume[aid]["upgradeMetalConsume"])
		r2=tonumber(consume[aid]["upgradeOilConsume"])
		r3=tonumber(consume[aid]["upgradeSiliconConsume"])
		r4=tonumber(consume[aid]["upgradeUraniumConsume"])
		reUpgradedMoney=tonumber(tankCfg[tankID]["upgradeTimeConsume"])
	end
    
    return r1,r2,r3,r4,reUpgradedMoney
end

function acRefitPlanVoApi:getUpgradePropConsume( )
	local aid,tankID = acRefitPlanVoApi:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	if consume and aid and consume[aid] and consume[aid]["upgradePropConsume"] then
		upgradePropConsume=consume[aid]["upgradePropConsume"]
	end
	return upgradePropConsume

end

function acRefitPlanVoApi:getMaxRate()
	local vo=self:getAcVo()
	if vo and vo.maxVate then
		return vo.maxVate
	end
	return 1
end
function acRefitPlanVoApi:canReward()

	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
    
end
