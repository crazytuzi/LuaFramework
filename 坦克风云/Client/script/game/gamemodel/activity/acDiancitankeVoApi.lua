acDiancitankeVoApi={}

function acDiancitankeVoApi:getAcVo()
	return activityVoApi:getActivityVo("diancitanke")
end

function acDiancitankeVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acDiancitankeVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acDiancitankeVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acDiancitankeVoApi:isSearchToday()
	return self:isToday()
end

function acDiancitankeVoApi:getTankID()
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

function acDiancitankeVoApi:getUpgradedTankResources()
	local aid,tankID = self:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local r1,r2,r3,r4,reUpgradedMoney=0,0,0,0,0
	if consume and aid then
		r1=tonumber(consume[aid]["upgradeMetalConsume"])
		r2=tonumber(consume[aid]["upgradeOilConsume"])
		r3=tonumber(consume[aid]["upgradeSiliconConsume"])
		r4=tonumber(consume[aid]["upgradeUraniumConsume"])
		reUpgradedMoney=tonumber(tankCfg[tankID]["upgradeTimeConsume"])
	end
    
    return r1,r2,r3,r4,reUpgradedMoney
end

function acDiancitankeVoApi:getUpgradePropConsume( )
	local aid,tankID = self:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	if consume and aid and consume[aid] and consume[aid]["upgradePropConsume"] then
		upgradePropConsume=consume[aid]["upgradePropConsume"]
	end
	return upgradePropConsume

end

function acDiancitankeVoApi:getRefitNeedTankIDAndNum( ... )
	local aid,tankID = self:getTankID()
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

function acDiancitankeVoApi:getRefitTankNeedCfg()
	local vo=self:getAcVo()
	if vo and vo.consume then
		return vo.consume
	end
	return {}
end

-- 得到金币
function acDiancitankeVoApi:getCost(tag,isMul)
	local vo=self:getAcVo()
	local cost = vo.costTb[tag]
	if isMul then
		cost=cost*vo.mulc
	end
	return cost
end

function acDiancitankeVoApi:getMul()
	local vo=self:getAcVo()
	return vo.mul
end


function acDiancitankeVoApi:setLastTime(time)
	local vo = self:getAcVo()
	vo.lastTime=time
end

function acDiancitankeVoApi:getScore()
	local vo = self:getAcVo()
	if vo.score then
		return vo.score
	end
	return 0
end

function acDiancitankeVoApi:setScore(score)
	local vo = self:getAcVo()
	vo.score=score
end

function acDiancitankeVoApi:getDecay(tag)
	local vo = self:getAcVo()
	return vo.decayTb[tag]
end

function acDiancitankeVoApi:getReward()
	local vo = self:getAcVo()
	return vo.reward
end

function acDiancitankeVoApi:returnTankData(idx)
	require "luascript/script/game/scene/tank/tankShowData"
	local vo = self:getAcVo()
	local aid,tankID = self:getTankID()
	if  tankShowData and tankShowData[aid] then
		return tankShowData[aid]
	end
	-- return vo.tankActionData[aid]	
end

function acDiancitankeVoApi:getRange()
	local vo = self:getAcVo()
	return vo.range
end

function acDiancitankeVoApi:getAddval()
	local vo = self:getAcVo()
	return vo.addval
end




function acDiancitankeVoApi:clearAll()
end