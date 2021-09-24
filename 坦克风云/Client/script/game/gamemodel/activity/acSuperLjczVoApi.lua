acSuperLjczVoApi={}

function acSuperLjczVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("ljcz3")
	end
	return self.vo
end

function acSuperLjczVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acSuperLjczVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	local costCfg=self:getCost()
	for k,v in pairs(costCfg) do
		local flag=self:checkIfReward(k)
		if flag==2 then
			return true
		end
	end
	return false
end

function acSuperLjczVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		--该活动没有领奖日，故不再需要减一天了时间了
		-- local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
		local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acSuperLjczVoApi:addTotalMoney(money)
	local acVo=self:getAcVo()
	if acVo then
		acVo.v=acVo.v+money
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged=true -- 强制更新数据
	end
end

function acSuperLjczVoApi:afterGetReward(id)
	local acVo=self:getAcVo()
	if acVo then
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged=true
	end
end

-- 自己当前的充值数
function acSuperLjczVoApi:getTotalMoney()
	local vo=self:getAcVo()
	if vo and vo.v then
		return vo.v
	end
	return 0
end

function acSuperLjczVoApi:getCost()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.cost then
		return vo.activeCfg.cost
	end
	return {}
end

function acSuperLjczVoApi:getRewardCfg()
	local vo=self:getAcVo()
	local rewardCfg={}
	if vo and vo.activeCfg and vo.activeCfg.reward then
		for k,v in pairs(vo.activeCfg.reward) do
			local rewardlist=FormatItem(v,nil,true)
			rewardCfg[k]=rewardlist
		end
	end
	return rewardCfg
end

function acSuperLjczVoApi:checkIfReward(id)
	local totalMoney=self:getTotalMoney()
	local costCfg=self:getCost()
	local cost=costCfg[id]
	local vo=self:getAcVo()
	if self:hasReward(id) then
		return 3
	elseif cost and tonumber(cost)<=totalMoney then
		return 2
	end
	return 1
end

function acSuperLjczVoApi:hasReward(id)
	local vo=self:getAcVo()
	if vo and vo.r then
		for k,v in pairs(vo.r) do
			if tonumber(v)==tonumber(id) then
				return true
			end
		end
	end
	return false
end

function acSuperLjczVoApi:getNextMoney()
	local totalMoney=self:getTotalMoney()
	local costCfg=self:getCost()
	for k,v in pairs(costCfg) do
		if totalMoney<tonumber(v) then
			return tonumber(v)-totalMoney
		end
	end
	return 0
end

function acSuperLjczVoApi:getRechargePercent()
	local per=0
	local vo=self:getAcVo()
	if vo then
		local totalMoney=self:getTotalMoney()
		local costCfg=self:getCost()
		local numDuan=SizeOfTable(costCfg)
		if numDuan==0 then
			numDuan=5
		end
		local everyPer=100/numDuan
		local diDuan=0 
		for i=1,numDuan do
			if totalMoney<=tonumber(costCfg[i]) then
				diDuan=i
				break
			end
		end

		if totalMoney>=costCfg[numDuan] then
			per=100
		elseif diDuan==1 then
			per=totalMoney/costCfg[1]/numDuan*100
		else
			per=(diDuan-1)*everyPer+(totalMoney-costCfg[diDuan-1])/(costCfg[diDuan]-costCfg[diDuan-1])/numDuan*100
		end
	end
	return per	
end

function acSuperLjczVoApi:isAddFlicker(pkey)
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.flickReward then
		local flickReward=FormatItem(vo.activeCfg.flickReward,nil,true)
		for k,v in pairs(flickReward) do
			if v.key==pkey then
				return true
			end
		end
	end
	return false
end

-- function acSuperLjczVoApi:addActivieIcon()
-- 	spriteController:addPlist("public/activeCommonImage1.plist")
--     spriteController:addTexture("public/activeCommonImage1.png")
-- end

-- function acSuperLjczVoApi:removeActivieIcon()
-- 	spriteController:removePlist("public/activeCommonImage1.plist")
--     spriteController:removeTexture("public/activeCommonImage1.png")
-- end

function acSuperLjczVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acSuperLjczVoApi:clearAll()
	self.vo=nil
end