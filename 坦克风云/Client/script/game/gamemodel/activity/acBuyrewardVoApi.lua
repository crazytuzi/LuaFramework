acBuyrewardVoApi = {
	name="",
}

function acBuyrewardVoApi:setActiveName(name)
	self.name=name
end

function acBuyrewardVoApi:getActiveName()
	return self.name
end

function acBuyrewardVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acBuyrewardVoApi:canReward(activeName)
	local isfree=true
	local vo = self:getAcVo(activeName)
	if vo and vo.f and vo.f==1 then --是否是第一次免费
		isfree=false
	end				
	-- if self:isToday()==true then
	-- 	isfree=false
	-- end
	return isfree
end

function acBuyrewardVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acBuyrewardVoApi:getCostByType(type)
	local acVo = self:getAcVo()
	if acVo then
		if type==1 then
			return acVo.cost1
		else
			return acVo.cost2
		end
	end
	return 0
end

function acBuyrewardVoApi:getBuyPropByType(type)
	local acVo = self:getAcVo()
	if acVo then
		if type==1 then
			return acVo.buyProp1
		else
			return acVo.buyProp2
		end
	end
	return 0
end

function acBuyrewardVoApi:getShowlist()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.showList
	end
	return {}
end

function acBuyrewardVoApi:getFlickReward()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.flickReward
	end
	return {}
end

function acBuyrewardVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acBuyrewardVoApi:getBgImg()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.bgImg
	end
	return 1
end

function acBuyrewardVoApi:getAcIcon(activeName)
	local acVo = self:getAcVo(activeName)
	if acVo then
		return acVo.acIcon
	end
	return "Icon_novicePacks"
end

function acBuyrewardVoApi:setF(flag)
	local acVo = self:getAcVo()
	if acVo then
		acVo.f=flag
	end
end

function acBuyrewardVoApi:getNameType(activeName)
	local acVo = self:getAcVo(activeName)
	if acVo and acVo.nameType then
		return acVo.nameType
	end
	return 1
end

function acBuyrewardVoApi:clearAll()
	self.name=""
end