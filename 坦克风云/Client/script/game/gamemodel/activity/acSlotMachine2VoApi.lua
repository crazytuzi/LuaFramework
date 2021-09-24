acSlotMachine2VoApi = {}

function acSlotMachine2VoApi:getAcVo()
	return activityVoApi:getActivityVo("slotMachine2")
end

function acSlotMachine2VoApi:getLastResultByLine(line)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.lastResult[line]
	end
	return 1
end

function acSlotMachine2VoApi:updateLastResult(result)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.lastResult = result
	end
end
-- 获取配置的每日免费抽奖次数
function acSlotMachine2VoApi:getCfgFree()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.free
	end
	return 0
end

-- 获取配置的非免费抽奖每次需要的金币
function acSlotMachine2VoApi:getCfgCost()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.cost
	end
	return 99999
end

-- 获取配置的模式倍数
function acSlotMachine2VoApi:getCfgMul()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.mul
	end
	return 0
end

-- 获取配置的模式倍数下花费的金币的倍数
function acSlotMachine2VoApi:getCfgMulCost()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.mulCost
	end
	return 99999
end

-- 获取配置的模式倍数下花费的金币
function acSlotMachine2VoApi:getMulCost()
	print("self:getCfgCost(): ",self:getCfgCost())
	print("self:getCfgMulCost(): ",self:getCfgMulCost())
	local cost = self:getCfgCost() * self:getCfgMulCost()
	if cost > 0 then
	    return cost
	end
	return 99999
end

function acSlotMachine2VoApi:getCfgConversionTable()
    local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.conversionTable
	end
	return {}
end

function acSlotMachine2VoApi:getCfgConversionTableByNum(num)
	local cfg = self:getCfgConversionTable()
	local cfgByNum = {}
	for k,v in pairs(cfg) do
		if v ~= nil and v.num == num then
			table.insert(cfgByNum, v)
		end
	end
	return cfgByNum
end

function acSlotMachine2VoApi:getCfgConversionTableByIdAndNum(id,num)
	local cfg = self:getCfgConversionTable()
	for k,v in pairs(cfg) do
		if v ~= nil and v.id == id and v.num == num then
			return v
		end
	end
	return nil
end

function acSlotMachine2VoApi:getTankCfgAndNumByCfg(cfg)
	for k,v in pairs(cfg) do
		if k ~= "index" then
			local tankId = tonumber(RemoveFirstChar(k))
            local tank = tankCfg[tankId]
            return tank, tonumber(v)
		end
	end
	return nil,nil
end

function acSlotMachine2VoApi:getPicById(id)
	if id == 1 then
		return "ShadowTank.png"
	elseif id == 2 then
		return "ShadowWeapon.png"
	elseif id == 3 then
		return "ShadowArtillery.png"
	elseif id == 4 then
		return "ShadowRocket.png"
	else
		return "ShadowTank.png"
	end
end


function acSlotMachine2VoApi:canReward()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		local cfgFree = self:getCfgFree()
		if G_isToday(acVo.t) == true then
            if acVo.v < cfgFree then
            	return true
            end
        else
        	if cfgFree > 0 then
        		return true
        	end
		end
	end
	return false
end

-- 是否可以免费抽取
function acSlotMachine2VoApi:checkIfFreeGame()
	return self:canReward()
end

-- 抽取奖励完成之后刷新数据
function acSlotMachine2VoApi:afterGameOver()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if G_isToday(acVo.t) == true then
            acVo.v = acVo.v + 1
        else
        	acVo.v = 1
        	acVo.t = base.serverTime
			acVo.refreshTs = G_getWeeTs(base.serverTime) + 86400
			print("acSlotMachine2VoApi:afterGameOver(): ", acVo.refreshTs)
		end
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

-- 从前一天过度到后一天时重新获取数据
function acSlotMachine2VoApi:refresh()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.t = G_getWeeTs(base.serverTime)
		acVo.v = 0
		acVo.refreshTs = acVo.t + 86400
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true
	end
	
end