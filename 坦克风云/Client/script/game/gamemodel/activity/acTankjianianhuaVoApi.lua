acTankjianianhuaVoApi = {}

function acTankjianianhuaVoApi:getAcVo()
	return activityVoApi:getActivityVo("tankjianianhua")
end

function acTankjianianhuaVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end
-- 获取配置的每日免费抽奖次数
function acTankjianianhuaVoApi:getCfgFree()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.free
	end
	return 0
end

-- 获取配置的非免费抽奖每次需要的金币
function acTankjianianhuaVoApi:getCfgCost()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.cost
	end
	return 99999
end

-- 获取配置的模式倍数
function acTankjianianhuaVoApi:getCfgMul()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.mul
	end
	return 0
end

-- 获取配置的模式倍数下花费的金币的倍数
function acTankjianianhuaVoApi:getCfgMulCost()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.mulCost
	end
	return 99999
end

-- 获取配置的模式倍数下花费的金币
function acTankjianianhuaVoApi:getMulCost()
	local cost = self:getCfgCost() * self:getCfgMulCost()
	if cost > 0 then
	    return cost
	end
	return 99999
end

function acTankjianianhuaVoApi:getCfgConversionTable()
    local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.conversionTable
	end
	return {}
end

function acTankjianianhuaVoApi:getCfgVersion()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.version then
		return acVo.version
	end
	return 1
end


function acTankjianianhuaVoApi:getShowIconList()
	local vo = self:getAcVo()
	if vo and vo.showIcon then
		return vo.showIcon
	end
	return {}
end

function acTankjianianhuaVoApi:getAllShowIconID()
	local iconlist = self:getShowIconList()
	local idList = {}
	if iconlist then
		for k,v in pairs(iconlist) do
			table.insert(idList,k)
		end
	end
	return idList

end
function acTankjianianhuaVoApi:getSpecialIcon()
	local vo = self:getAcVo()
	if vo and vo.specialIcon then
		return vo.specialIcon
	end
	return {}
end
function acTankjianianhuaVoApi:checkIsSpecialIconById(id)
	local specialIconList = self:getSpecialIcon()
	if specialIconList then
		for k,v in pairs(specialIconList) do
			if v and v== id then
				return true
			end
		end
	end
	return false
end

function acTankjianianhuaVoApi:getShowIconById(id)
	local iconlist = self:getShowIconList()
	local icon
	if self:checkIsSpecialIconById(id)== true then
		icon = CCSprite:createWithSpriteFrameName("universal.png")
		icon:setScale(0.7)
	else
		if iconlist then
			for k,v in pairs(iconlist) do
				if k and k == id and v then
					local award = FormatItem(v)
					for k,v in pairs(award) do
						--icon = G_getItemIcon(v,100)
						if v.type=="o" then
							tid = GetTankOrderByTankId(v.id)
							icon = CCSprite:createWithSpriteFrameName("t"..tid.."_1.png")
							icon:setScale(0.7)
						elseif v.type =="u" then
							icon = CCSprite:createWithSpriteFrameName("GoldImage.png")
							icon:setScale(1.2)
						end
					end
				end
			end
		end
	end
	return icon
	
end

function acTankjianianhuaVoApi:getRewardList()
	local vo = self:getAcVo()
	if vo and vo.rewardList then
		return vo.rewardList
	end
	return {}
end
function acTankjianianhuaVoApi:getRewardListByID(id)
	local rewardList = self:getRewardList()
	if rewardList then
		for k,v in pairs(rewardList) do
			if k and k == id and v then
				return v
			end
		end
	end
	return {}
end

-- 是否可以免费抽取
function acTankjianianhuaVoApi:checkIfFreeGame()
	return self:canReward()
end

function acTankjianianhuaVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

function acTankjianianhuaVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acTankjianianhuaVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end