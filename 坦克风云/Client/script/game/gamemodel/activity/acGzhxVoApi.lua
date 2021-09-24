acGzhxVoApi={
	name=nil,
}

function acGzhxVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acGzhxVoApi:setActiveName(name)
	self.name=name
end

function acGzhxVoApi:getActiveName()
	return self.name or "gzhx"
end
function acGzhxVoApi:clearAll()
	self.name=nil
end

function acGzhxVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acGzhxVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acGzhxVoApi:isToday(activeName)
	local isToday=false
	local vo = self:getAcVo(activeName)
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acGzhxVoApi:getBigRewardsCfg()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.reward
	end
	return {}
end

function acGzhxVoApi:getBigrewardsRate()
	local vo=self:getAcVo()
	if vo and vo.rate then
		return vo.rate
	end
	return 1
end

function acGzhxVoApi:getLotteryOnceCost( ... )
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.cost
	end
	return 0
end

function acGzhxVoApi:getLotteryTenCost( ... )
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.cost*vo.activeCfg.mul*(vo.activeCfg.mulc/vo.activeCfg.mul)
	end
	return 0
end

function acGzhxVoApi:getRefitTankNeedCfg( ... )
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.consume
	end
	return {}
end

function acGzhxVoApi:getTankID(activeName)
	local vo=self:getAcVo(activeName)
	local aid
	local tankID
	if vo and vo.activeCfg then
		for k,v in pairs(vo.activeCfg.consume) do
			aid=k
		end
	end
	if aid then
		local arr = Split(aid,"a")
		tankID =arr[2]
	end
	return aid,tonumber(tankID)
end
function acGzhxVoApi:getRefitNeedTankIDAndNum( ... )
	local aid,tankID = acGzhxVoApi:getTankID()
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

function acGzhxVoApi:getUpgradedTankResources()
	local aid,tankID = acGzhxVoApi:getTankID()
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

function acGzhxVoApi:getUpgradePropConsume( )
	local aid,tankID = acGzhxVoApi:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	if consume and aid and consume[aid] and consume[aid]["upgradePropConsume"] then
		upgradePropConsume=consume[aid]["upgradePropConsume"]
	end
	return upgradePropConsume

end

function acGzhxVoApi:getMaxRate()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.maxVate
	end
	return 1
end
function acGzhxVoApi:getActivityIcon(activeName)
	local aid,tankID = acGzhxVoApi:getTankID(activeName)
	return tankCfg[tankID].icon
end
function acGzhxVoApi:canReward(activeName)

	local isfree=true							--是否是第一次免费
	if self:isToday(activeName)==true then
		isfree=false
	end
	return isfree
    
end
