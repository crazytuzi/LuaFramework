acLjczVoApi={}

function acLjczVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("ljcz")
	end
	return self.vo
end

function acLjczVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acLjczVoApi:canReward()
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

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acLjczVoApi:addTotalMoney(money)
	local acVo=self:getAcVo()
	if acVo then
		acVo.v=acVo.v+money
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged=true -- 强制更新数据
	end
end

function acLjczVoApi:afterGetReward(id)
	local acVo=self:getAcVo()
	if acVo then
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged=true
	end
end

-- 自己当前的充值数
function acLjczVoApi:getTotalMoney()
	local vo=self:getAcVo()
	if vo and vo.v then
		return vo.v
	end
	return 0
end

function acLjczVoApi:getCost()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.cost then
		return vo.activeCfg.cost
	end
	return {}
end

function acLjczVoApi:getRewardCfg()
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

function acLjczVoApi:checkIfReward(id)
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

function acLjczVoApi:hasReward(id)
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

function acLjczVoApi:getNextMoney()
	local totalMoney=self:getTotalMoney()
	local costCfg=self:getCost()
	for k,v in pairs(costCfg) do
		if totalMoney<tonumber(v) then
			return tonumber(v)-totalMoney
		end
	end
	return 0
end

function acLjczVoApi:getRechargePercent()
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

function acLjczVoApi:isAddFlicker(pkey)
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

-- function acLjczVoApi:addActivieIcon()
-- 	spriteController:addPlist("public/activeCommonImage1.plist")
--     spriteController:addTexture("public/activeCommonImage1.png")
-- end

-- function acLjczVoApi:removeActivieIcon()
-- 	spriteController:removePlist("public/activeCommonImage1.plist")
--     spriteController:removeTexture("public/activeCommonImage1.png")
-- end

function acLjczVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acLjczVoApi:clearAll()
	self.vo=nil
end