acYuebingshenchaVoApi={}

function acYuebingshenchaVoApi:getAcVo()
	return activityVoApi:getActivityVo("ybsc")
end

function acYuebingshenchaVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acYuebingshenchaVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acYuebingshenchaVoApi:getVipDiscount( )
	local vo = self:getAcVo()
	if vo and vo.vipDiscount then
		return vo.vipDiscount
	end
end

function acYuebingshenchaVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acYuebingshenchaVoApi:getCost()
	local vo = self:getAcVo()
	local vipDiscount = self:getVipDiscount()
	local subCost = vipDiscount and vipDiscount[playerVoApi:getVipLevel()+1] or 0

	if vo and vo.cost then
		return vo.cost-subCost,vo.cost
	end
	
	return 1000
end

function acYuebingshenchaVoApi:getMulCost()
	local vo = self:getAcVo()
	local vipDiscount = self:getVipDiscount()
	local cost,oldCost = self:getCost()
	if vipDiscount then
		return cost * 9,oldCost*9
	else
		if vo and vo.mulCost then
			return vo.mulCost
		end
	end
	return 10000
end

function acYuebingshenchaVoApi:getLastTime()
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		return vo.lastTime
	end
	return 0
end

function acYuebingshenchaVoApi:getReward()
	local vo = self:getAcVo()
	local rewardTb = {}
	if vo and vo.reward then
		for i=1,#vo.reward do
			for k,v in pairs(vo.reward[i]) do
				local result=Split(v[1], '_') 
				table.insert(rewardTb,{k,result[2],v[2],v[3]})
			end
		end
	end
	return rewardTb
end

function acYuebingshenchaVoApi:getTankID()
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

function acYuebingshenchaVoApi:getUpgradedTankResources(aid,tankID)
	-- local aid,tankID = self:getTankID()
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

function acYuebingshenchaVoApi:getUpgradePropConsume(aid,tankID)
	-- local aid,tankID = self:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	if consume and aid and consume[aid] and consume[aid]["upgradePropConsume"] then
		upgradePropConsume=consume[aid]["upgradePropConsume"]
	end
	return upgradePropConsume

end

function acYuebingshenchaVoApi:getRefitNeedTankIDAndNum(aid,tankID)
	-- local aid,tankID = self:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local needAidTb={}
	local needTankIDTb={}
	local needNumTb={}
	local upgradeShipConsume = {}
	if aid and consume and consume[aid] and consume[aid]["upgradeShipConsume"] then
		upgradeShipConsume=consume[aid]["upgradeShipConsume"]
		-- needAidTb = upgradeShipConsume[1]
		-- needNum = upgradeShipConsume[2]
		for i=1,#upgradeShipConsume do
			needAidTb[i]=upgradeShipConsume[i][1]
			needNumTb[i]=upgradeShipConsume[i][2]
		end
	end
	if needAidTb then
		for k,v in pairs(needAidTb) do
			local arr = Split(v,"a")
			needTankIDTb[k] =tonumber(arr[2])
		end
		
	end
	return needTankIDTb,needNumTb
end

function acYuebingshenchaVoApi:getRefitTankNeedCfg()
	local vo=self:getAcVo()
	if vo and vo.consume then
		return vo.consume
	end
	return {}
end

function acYuebingshenchaVoApi:getNowP()
	local  vo = self:getAcVo()
	if vo and vo.nowP then
		return vo.nowP
	end
	return {}
end

function acYuebingshenchaVoApi:updataData(data)
	local  vo = self:getAcVo()
	vo:updateSpecialData(data)
end

function acYuebingshenchaVoApi:getVersion()
	local  vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acYuebingshenchaVoApi:returnTankData()
	local vo = self:getAcVo()
	local aid= "a" .. 10095
	if self:getVersion()==2 or self:getVersion()==4 then
		aid= "a" .. 20155
	end
	
	if vo and vo.tankActionData then
		return vo.tankActionData[aid]
	end
	
end


function acYuebingshenchaVoApi:clearAll()
end