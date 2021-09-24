acGwkhVoApi={}

function acGwkhVoApi:getAcVo()
	return activityVoApi:getActivityVo("gwkh")
end

function acGwkhVoApi:canReward()
	return false
end

function acGwkhVoApi:setActiveName(name)
	self.name=name
end

function acGwkhVoApi:getTimeStr( ... )
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":"..activeTime
    end
    return str
end

--带d的与后端交互的时间
function acGwkhVoApi:getDay(  )
	local str = ""
	local vo = self:getAcVo()
	if vo then
		local day = math.ceil((base.serverTime-vo.st)/86400)
		return "d"..day
	end
	return str
end

--单纯的前端的显示时间
function acGwkhVoApi:getToday(  )
	local day = 0
	local vo = self:getAcVo()
	if vo then
		local day = math.ceil((base.serverTime-vo.st)/86400)
		return day
	end
	return day
end

function acGwkhVoApi:getTodayCost()
	local vo = self:getAcVo()
	local todayCost = 0
	if vo then
		local day = self:getDay()
		if vo.goldCost and vo.goldCost[day] then
			todayCost = vo.goldCost[day]
			return todayCost
		end
		return todayCost
	end
	return todayCost
end

function acGwkhVoApi:getTodayCostStr(  )
	local vo = self:getAcVo()
	local todayCost = self:getTodayCost()
	local str = ""
	if vo and todayCost then
		str=getlocal("activity_gwkh_totalgold") .. "："..todayCost
	end
	return str
end


function acGwkhVoApi:getActiveCfg()
	local vo = self:getAcVo()
	if vo then
    	local rewardTb = vo.activeCfg
    	return rewardTb
    end
    
end

function acGwkhVoApi:getDailyCostCfg( index )
	local dailyCostCfg = self:getActiveCfg().dailyReward[index].needgold
	return dailyCostCfg
end

function acGwkhVoApi:getTodayRewardList( index)
	local rewardList = self:getActiveCfg().dailyReward[index].reward
	return rewardList
end

--获取后端领取今日奖励的数据
function acGwkhVoApi:ifHasRewardToday(day,index)
	local vo = self:getAcVo()
	if vo then
		local hasReward = 0
		if vo.hasRewardToday and vo.hasRewardToday[day] then
			local hasRewardCfg = vo.hasRewardToday[day]
			hasReward= hasRewardCfg[index]
			if hasReward==index then
				return true
			end
		end
	end
	return false
end

function acGwkhVoApi:getTotalCostCfg( index )
	local totalCostCfg = self:getActiveCfg().totalReward[index].needgold
	return totalCostCfg
end

function acGwkhVoApi:getTotalDayCfg( index)
	local totalNeedDay = self:getActiveCfg().totalReward[index].needday	
	return totalNeedDay
end

function acGwkhVoApi:getTotalRewardNum(  )
	local tb = self:getActiveCfg().totalReward
	local num = 0
	if tb then
		for k,v in pairs(tb) do
			num=num+1
		end
	end
	return num	
end

function acGwkhVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

--获取配置里的累计奖励列表
function acGwkhVoApi:getTotalRewardList( index )
	local totalRewardList = self:getActiveCfg().totalReward[index].reward
	return totalRewardList
end

--获取后端领取累计奖励的数据
function acGwkhVoApi:getTotalHasRewardTb( )
	local tb = {}
	local vo = self:getAcVo()
	if vo and vo.hasRewardTotal then
		tb=vo.hasRewardTotal
	end
	return tb
end

--是否已经领取累计奖励
function acGwkhVoApi:ifHasRewardTotal( index )
	local tb = self:getTotalHasRewardTb()
	if tb then
		for k,v in ipairs(tb) do
			if v == index then
				return true;
			end
		end
	end
	return false;
end

function acGwkhVoApi:getRewardTitleStr( index )
	local today = self:getToday()
	local vo = self:getAcVo()
	local needgold = self:getTotalCostCfg(index)
	local needday = self:getTotalDayCfg(index)
	local daynum = 0
	if vo and vo.goldCost then
		local everyDayCostTb = vo.goldCost
		for k,v in pairs(everyDayCostTb) do
			if v>=needgold then
				daynum = daynum+1
			end
		end
	end
	if daynum>needday then
		daynum=needday
	end

	local messageLabel
	local width = G_VisibleSizeWidth/4*3
	
	if index==1 then
		if daynum==needday then
			messageLabel=GetTTFLabel(getlocal("activity_gwkh_rewardDes1",{needday,daynum,needday}),24,true)
		else
			local str=getlocal("activity_gwkh_rewardDes1",{needday,daynum,needday})
			messageLabel=G_getRichTextLabel(str,{G_ColorWhite,G_ColorGreen,G_ColorWhite},24,width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		end
	else
		if daynum==needday then
			messageLabel=GetTTFLabel(getlocal("activity_gwkh_rewardDes2",{needday,needgold,daynum,needday}),24,true)
		else
			local str = getlocal("activity_gwkh_rewardDes2",{needday,needgold,daynum,needday})
			messageLabel=G_getRichTextLabel(str,{G_ColorWhite,G_ColorGreen,G_ColorWhite},24,width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		end
	end
	return messageLabel
end

function acGwkhVoApi:checkIsToday( today )
	local day = self:getToday()
	if today==day then
		return false
	else
		return true
	end
end

function acGwkhVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage3.plist")
	spriteController:addTexture("public/activeCommonImage3.png")
end

function acGwkhVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage3.plist")
	spriteController:removeTexture("public/activeCommonImage3.png")
end