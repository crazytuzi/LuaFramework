acPeijianhuzengVoApi={}

function acPeijianhuzengVoApi:getAcVo()
	return activityVoApi:getActivityVo("sendaccessory")
end

function acPeijianhuzengVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acPeijianhuzengVoApi:canReward()
	local isfree=false							
	local flag1 = self:isReceive(1)
	local flag2 = self:isReceive(2)
	local alreadyCost = self:getAleadyCost()
	local cost1 = self:getCost(1)
	local cost2 = self:getCost(2)
	if alreadyCost and cost1 and alreadyCost>=cost1 and flag1==false then
		isfree=true
	end
	if alreadyCost and cost2 and alreadyCost>=cost2 and flag2==false then
		isfree=true
	end
	return isfree
end

function acPeijianhuzengVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acPeijianhuzengVoApi:getCost(tag)
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost[tag] 
	end
	
end

function acPeijianhuzengVoApi:getReward()
	local vo=self:getAcVo()
	local reward = vo.reward
	local rewardItem={}
	for i,v in ipairs(reward) do
		local item = FormatItem(v)
		table.insert(rewardItem,item[1])
	end
	return rewardItem
end

-- 玩家在线充值后，后台将新的充值金额推给前台，前台要强制更新数据
function acPeijianhuzengVoApi:addGold(money)
	local vo = self:getAcVo()
	if vo ~= nil then
		vo.v = vo.v + money
		vo.stateChanged = true -- 强制更新数据
	end
end

function acPeijianhuzengVoApi:getAleadyCost()
	local vo = self:getAcVo()
	return vo.v or 0
end

function acPeijianhuzengVoApi:setR(r)
	local vo = self:getAcVo()
	vo.r = r
end

function acPeijianhuzengVoApi:isReceive(flag)
	local vo = self:getAcVo()
	local receiveTb=vo.r or {}
	for k,v in pairs(receiveTb) do
		if flag==v then
			return true
		end
	end
	return false
end


function acPeijianhuzengVoApi:clearAll()
end