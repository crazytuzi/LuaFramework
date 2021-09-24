acSinglesVoApi = {}

function acSinglesVoApi:getAcVo()
	return activityVoApi:getActivityVo("singles")
end
function acSinglesVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acSinglesVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end


function acSinglesVoApi:getTokenCfgForShow()
	return activityCfg.singles
end

function acSinglesVoApi:getTokenCfgForShowByPid(pid)
	local cfg = self:getTokenCfgForShow()
	for k,v in pairs(cfg) do
		if k == pid then
			return v
		end
	end
	return nil
end

function acSinglesVoApi:getSelfTokens()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.token then
		return acVo.token
	end
	return {}
end

function acSinglesVoApi:getTokenNumByID(mtype)
	local Tokens = self:getSelfTokens()
	if Tokens ~= nil and type(Tokens)=="table" then
		for k,v in pairs(Tokens) do
			if k == mtype and v then
				return tonumber(v)
			end
		end
	end
	return 0
end

function acSinglesVoApi:updateSelfTokens(mtype,num)
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		if acVo.token==nil then
			acVo.token = {}
		end
		local add = false
		for k,v in pairs(acVo.token) do
			if k == mtype and v then
				acVo.token[mtype] = tonumber(v + num)
				add = true
			end
		end
		if add == false then
			acVo.token[mtype] = tonumber(num)
		end
	end
end

function acSinglesVoApi:getLotteryOnceCost()
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end
function acSinglesVoApi:getLotteryTenCost()
	local vo=self:getAcVo()
	if vo and vo.cost and vo.mul and vo.mulc then
		return tonumber(vo.cost*vo.mulc)
	end
	return 0
end
function acSinglesVoApi:getLotteryOldTenCost()
	local vo=self:getAcVo()
	if vo and vo.cost and vo.mul then
		return tonumber(vo.cost*vo.mul)
	end
	return 0
end
function acSinglesVoApi:getLotteryTenOldRate()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.mul then
		return acVo.mul
	end
	return 0
end
function acSinglesVoApi:getLotteryTenRate()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.mulc then
		return acVo.mulc
	end
	return 0
end

function acSinglesVoApi:getVipReward()
	local vo=self:getAcVo()
	local vipLv = playerVoApi:getVipLevel()
	local vipReward = {}
	if vo and vo.vipReward then
		for k,v in pairs(vo.vipReward) do
			if v and type(v) == "table" then
				if v[1] and v[2] and vipLv>=v[1] then
					return v[2]
				end
			end
		end
	end
	return {}
end


function acSinglesVoApi:getShopCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.shopItem then
		return acVo.shopItem
	end
	return {}
end

function acSinglesVoApi:getHasBuyNumByID(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.hasBuy and type(acVo.hasBuy)=="table" then
		for k,v in pairs(acVo.hasBuy) do
			if k and v and k == id then
				return tonumber(v)
			end 
		end
	end
	return tonumber(0)
end

function acSinglesVoApi:updateHasBuyNumByID(id,num)
	local acVo = self:getAcVo()
	if num ==nil then
		num = 1 
	end
	if acVo ~= nil then
		if acVo.hasBuy == nil then
			acVo.hasBuy = {}
		end
		local isBuy = false
		for k,v in pairs(acVo.hasBuy) do
			if k and v and k == id then
				acVo.hasBuy[id]=num+v
				isBuy = true
			end 
		end
		if isBuy == false then
			acVo.hasBuy[id]=num
		end

	end
end

function acSinglesVoApi:getGoodsCfg( )
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.goods then
		return acVo.goods
	end
	return {}
end

function acSinglesVoApi:getIsChatByID(id)
	local goodsCfg = self:getGoodsCfg()
	if goodsCfg then
		for k,v in pairs(goodsCfg) do
			if v and v == id then
				return true
			end
		end
	end
	return false
end

function acSinglesVoApi:getCircleListCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.circleList then
		return acVo.circleList
	end
	return {}
end

function acSinglesVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acSinglesVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acSinglesVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end