acImminentVoApi ={}

function  acImminentVoApi:getAcVo( )
	return activityVoApi:getActivityVo("yichujifa")
end
function acImminentVoApi:canReward()
	if self:isToday()== false then
		return true
	end
	return false
end

function acImminentVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	-- print("isToday---->",isToday)
	return isToday
end
function acImminentVoApi:setToday( time )
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		vo.lastTime =time
	end
end
------------------------------------tab3
function acImminentVoApi:getRefitTankNeedCfg()
	local vo=self:getAcVo()
	if vo and vo.consume then
		return vo.consume
	end
	return {}
end

function acImminentVoApi:getTankID()
	local vo=self:getAcVo()
	local aidTb={}
	local tankIDTb={}
	if vo and vo.consume then
		for k,v in pairs(vo.consume) do
			aidTb[v.index]=k
		end
	end
	if aidTb then
		for k,v in pairs(aidTb) do
			local arr = Split(v,"a")
			tankIDTb[k] =tonumber(arr[2])
		end
	end
	return aidTb,tankIDTb
end

function acImminentVoApi:getUpgradedTankResources(aid,tankID)
	-- local aid,tankID = self:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local r1,r2,r3,r4,reUpgradedMoney=0,0,0,0,0
	if consume and aid then
		aid =tonumber(RemoveFirstChar(aid))
		r1=tonumber(tankCfg[aid]["upgradeMetalConsume"])
		r2=tonumber(tankCfg[aid]["upgradeOilConsume"])
		r3=tonumber(tankCfg[aid]["upgradeSiliconConsume"])
		r4=tonumber(tankCfg[aid]["upgradeUraniumConsume"])
		reUpgradedMoney=tonumber(tankCfg[tankID]["upgradeTimeConsume"])
	end
    
    return r1,r2,r3,r4,reUpgradedMoney
end

function acImminentVoApi:getUpgradePropConsume(aid,tankID)
	-- local aid,tankID = self:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	aid =tonumber(RemoveFirstChar(aid))
	if consume and aid and tankCfg[aid] and tankCfg[aid]["upgradePropConsume"] then
		upgradePropConsume=tankCfg[aid]["upgradePropConsume"]
	end
	return upgradePropConsume

end

function acImminentVoApi:getRefitNeedTankIDAndNum(aid,tankID)
	-- local aid,tankID = self:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local needAidTb={}
	local needTankIDTb={}
	local needNumTb={}
	local upgradeShipConsume = {}
	aid =tonumber(RemoveFirstChar(aid))
	if aid and consume and tankCfg[aid] and tankCfg[aid]["upgradeShipConsume"] then
		upgradeShipConsume=tankCfg[aid]["upgradeShipConsume"]
		local dataTb=Split(upgradeShipConsume,",")
		needAidTb[1]=dataTb[1]
		needNumTb[1]=dataTb[2]
	end
	if needAidTb then
		-- for k,v in pairs(needAidTb) do
			needTankIDTb[1] =tonumber(needAidTb[1])
		-- end
	end
	return needTankIDTb,needNumTb
end

------------------------------------tab3⬆️
------------------------------------tab2
function acImminentVoApi:getUpperLimit()
	local vo = self:getAcVo()
	if vo and vo.upperLimit then
		return vo.upperLimit*100
	end
	return 0
end
function acImminentVoApi:getIncreasePick()
	local vo = self:getAcVo()
	if vo and vo.increasePick then
		return vo.increasePick*100
	end
	return 0
end
------------------------------------tab2⬆️
------------------------------------tab1


function acImminentVoApi:getCost(idx)--两种挖矿的所需的金币数 1，2
	local vo = self:getAcVo()
	if vo and vo["cost"..idx] then
		return vo["cost"..idx]
	end
	return 9999
end

function acImminentVoApi:getDeep(idx)--1 普通探测 挖掘范围 2 深度探测 探测范围
	local vo = self:getAcVo()
	if vo and vo["deep"..idx] then
		if  vo["deep"..idx][1] ~= vo["deep"..idx][2] then
			return vo["deep"..idx][1].."m-"..vo["deep"..idx][2].."m"
		else
			return vo["deep"..idx][1].."m"
		end
	end
	return {}
end

function acImminentVoApi:getBigDeep( )
	local  vo = self:getAcVo()
	if vo and vo.deep1 then
		return vo.deep1[1]
	end
	-- print("vo.deep2[1]----->",vo.deep2[1])
	return 100
end

function acImminentVoApi:getFree()-- 每日获得 免费次数
	local vo = self:getAcVo()
	if vo and vo.free then
		return vo.free
	end
	return 0
end

function acImminentVoApi:getReCost()-- 重置所需的金币数
	local vo = self:getAcVo()
	if vo and vo.reCost then
		return vo.reCost
	end
	return 9999
end

function acImminentVoApi:getDeepStep() --岩层分布{20,40,60,80,100}
	local vo = self:getAcVo()
	if vo and vo.deepStep then
		return vo.deepStep
	end
	return {}
end

function acImminentVoApi:getClientShow() --岩层奖励池
	local vo = self:getAcVo()
	local clientShowTb = {}
	local clientShow = vo.clientShow
	if vo and clientShow then
		for i=1,SizeOfTable(clientShow) do
			local awardTb = FormatItem(clientShow["pool"..i],false,true)
			table.insert(clientShowTb,awardTb)
		end
		-- for k,v in pairs(vo.clientShow) do
		-- 	local awardTb = FormatItem(v,false,true)
		-- 	table.insert(clientShowTb,awardTb)
		-- end
		return clientShowTb
	end
	return {}
end

function acImminentVoApi:getDeepStepClientReward() --岩层奖励池
	local vo = self:getAcVo()
	local deepStepRewardTb = {}
	if vo and vo.deepStepClientReward then
		for k,v in pairs(vo.deepStepClientReward) do
			local awardTb = FormatItem(v,false)[1]
			table.insert(deepStepRewardTb,awardTb)
		end
		return deepStepRewardTb
	end
	return {}
end


function acImminentVoApi:getDeepDepth()-- 当前挖掘深度
	local vo = self:getAcVo()
	if vo and vo.deepDepth then
		return vo.deepDepth
	end
	return 0
end

function acImminentVoApi:setDeepDepth(deepDepth)
	local vo = self:getAcVo()
	if vo and deepDepth then
		vo.deepDepth =deepDepth
	else
		vo.deepDepth =0
	end
end

function acImminentVoApi:getCurReward()-- 当前得到的奖励（普通）
	local vo = self:getAcVo()
	local curRewardTb = {}
	if vo and vo.curReward then
		if vo.curReward and SizeOfTable(vo.curReward)>0 then
			for k,v in pairs(vo.curReward) do
				local award = FormatItem(v,false)[1]
				table.insert(curRewardTb,award)
			end
		end
	end
	return curRewardTb
end

function acImminentVoApi:setCurReward(curReward)
	local vo = self:getAcVo()
	if vo and curReward then
		vo.curReward =curReward
	else
		vo.curReward ={}
	end
end

function acImminentVoApi:getCurBigReward()-- 当前得到的奖励（大大大大）
	local vo = self:getAcVo()
	local curRewardTb = {}
	if vo and vo.curBigReward then
		for k,v in pairs(vo.curBigReward) do
				local award = FormatItem(v,false)[1]
				table.insert(curRewardTb,award)
			end
	end
	return curRewardTb
end

function acImminentVoApi:setCurBigReward(curBigReward)
	local vo = self:getAcVo()
	if vo and curBigReward then
		vo.curBigReward =curBigReward
	else
		vo.curBigReward ={}
	end
end

function acImminentVoApi:returnTankData()
	local vo = self:getAcVo()
	-- local aid= "a" .. 10095
	-- if self:getVersion()==2 then
	-- 	aid= "a" .. 20155
	-- end
	
	if vo and vo.tankActionData then
		return vo.tankActionData[aid]
	end
	
end

function acImminentVoApi:getCurFloorNums()-- 当前挖掘深度
	local vo = self:getAcVo()
	if vo and vo.curFloorNums then
		return vo.curFloorNums
	end
	return 0
end

function acImminentVoApi:setCurFloorNums(curFloorNums)
	local vo = self:getAcVo()
	if vo and curFloorNums then
		vo.curFloorNums =curFloorNums
	else
		vo.curFloorNums =0
	end
end



