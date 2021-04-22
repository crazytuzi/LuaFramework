

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityDivination = class("QActivityDivination",QActivityRoundsBaseChild)
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QActivityDivination:ctor( ... )
	-- body
	QActivityDivination.super.ctor(self,...)
	self._awardInfo = nil
	self._curServerRank = nil
	self._allServerRank = nil
	self._scoreRewards = nil
	self._curScore = nil
	
end


function QActivityDivination:getCurServerRank(  )
	-- body
	return self._curServerRank  or 0
end

function QActivityDivination:getAllServerRank(  )
	-- body
	return self._allServerRank  or 0
end

function QActivityDivination:dailyRewardInfoIsGet( id )
	-- body
	for k, v in pairs(self._scoreRewards or {}) do
		if id == v then
			return true
		end
	end
	return false
end

function QActivityDivination:getDailyScore(  )
	-- body
	return self._curScore or 0
end

function QActivityDivination:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE})
	remote.redTips:removeNodeByName("QUIPageMainMenu_DivinationTips", true)
end

function QActivityDivination:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE})
end

function QActivityDivination:handleOnLine( )
	-- body
	self:initDivinationTips()
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE})

end

function QActivityDivination:handleOffLine( )	
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE})
	remote.redTips:removeNodeByName("QUIPageMainMenu_DivinationTips", true)
end

function QActivityDivination:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then

	end
end


function QActivityDivination:udpateMyRankInfo( isElite, rank )
	-- body
	if rank and rank > 0 then
		local isChange = false
		if isElite then
			local curRank = self._allServerRank or 0
			isChange = rank ~= curRank
			self._allServerRank = rank
		else
			local curRank = self._curServerRank or 0
			isChange = rank ~= curRank
			self._curServerRank = rank
		end
		if isChange then		
			remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE})
		end
	end
end

--占卜 红点
function QActivityDivination:initDivinationTips(  )
	-- body
	remote.redTips:createTipsNode("QUIPageMainMenu_DivinationTips")
	remote.redTips:createTipsNode("QUIActivityDialogDivination_AwardsTips", "QUIPageMainMenu_DivinationTips")
	remote.redTips:createTipsNode("QUIActivityDialogDivination_DivinationTips", "QUIPageMainMenu_DivinationTips")
	remote.redTips:createTipsNode("QUIActivityDialogDivination_ScoreTips", "QUIPageMainMenu_DivinationTips")
	-- 初始化红点状
	remote.redTips:setTipsStateByName("QUIActivityDialogDivination_AwardsTips", self:checkAwardsRedTips())
	remote.redTips:setTipsStateByName("QUIActivityDialogDivination_DivinationTips", self:checkDivinationItemRedTips())
	remote.redTips:setTipsStateByName("QUIActivityDialogDivination_ScoreTips", self:checkScoreRedTips())
	
end


-- function QActivityDivination:checkRedTips( data )
-- 	-- body
-- 	if not self.isOpen or not self.isActivityNotEnd then
-- 		return false
-- 	end
-- 	return false
-- end

-- function QActivityDivination:getData( )
	
-- 	return data
-- end


function QActivityDivination:checkAwardsRedTips()
	-- body
	if self._awardInfo then
		for k, v in pairs(self._awardInfo) do
			if v.isActive and not v.isTaken then
				return true
			end
		end
	end
	return false
end

function QActivityDivination:checkScoreRedTips(  )
	-- body
	local funcName = "zhanbu"
	local configs = QStaticDatabase:sharedDatabase():getScoreAwardsByLevel(funcName, remote.user.level)
    for k ,v in pairs(configs) do
        if not self:dailyRewardInfoIsGet(v.id) and (self._curScore or 0) >= v.condition then
			return true
		end
    end
    return false
end


function QActivityDivination:checkDivinationItemRedTips( )
	-- body
	local num = remote.items:getItemsNumByID(40) or 0
	return num > 0
end


function QActivityDivination:getActivityInfoWhenLogin(  )
	-- body
	local request = {api = "DIVINATION_GET"}
    app:getClient():requestPackageHandler("DIVINATION_GET", request, function(data)
    	if data.divinationGetResponse then
    		if data.divinationGetResponse.divinationInfo and data.divinationGetResponse.divinationInfo.awards then
				self._awardInfo = data.divinationGetResponse.divinationInfo.awards
			end
			if data.divinationGetResponse.normalRank then
				self._curServerRank = data.divinationGetResponse.normalRank
			end
			if data.divinationGetResponse.centerRank then
				self._allServerRank = data.divinationGetResponse.centerRank
			end
			if data.divinationGetResponse.divinationScoreReward then
				self._scoreRewards = data.divinationGetResponse.divinationScoreReward
			end

			if data.divinationGetResponse.divinationScore then
				self._curScore = data.divinationGetResponse.divinationScore
			end
		end
		self:initDivinationTips()
    end, fail)
end

function QActivityDivination:requestDivinationInfo(success, fail)
	-- body
	local request = {api = "DIVINATION_GET"}
    app:getClient():requestPackageHandler("DIVINATION_GET", request, function(data)
	    if data.divinationGetResponse then
	    	if data.divinationGetResponse.divinationInfo and data.divinationGetResponse.divinationInfo.awards then
				self._awardInfo = data.divinationGetResponse.divinationInfo.awards
				remote.redTips:setTipsStateByName("QUIActivityDialogDivination_AwardsTips", self:checkAwardsRedTips())
			end
			if data.divinationGetResponse.normalRank then
				self._curServerRank = data.divinationGetResponse.normalRank
			end
			if data.divinationGetResponse.centerRank then
				self._allServerRank = data.divinationGetResponse.centerRank
			end
			if data.divinationGetResponse.divinationScoreReward then
				self._scoreRewards = data.divinationGetResponse.divinationScoreReward
			end
			if data.divinationGetResponse.divinationScore then
				self._curScore = data.divinationGetResponse.divinationScore
			end
		end
		if success then
			success(data)
		end
    end, fail)
end


function QActivityDivination:requestDivinationBegin(count, success, fail)
	-- body
	local divinationDivineRequest = { count = count}
	local request = {api = "DIVINATION_DIVINE", divinationDivineRequest = divinationDivineRequest}
    app:getClient():requestPackageHandler("DIVINATION_DIVINE", request, function(data)
    	if data.divinationDivineResponse then
    		if data.divinationDivineResponse.divinationInfo and data.divinationDivineResponse.divinationInfo.awards then
				self._awardInfo = data.divinationDivineResponse.divinationInfo.awards
				remote.redTips:setTipsStateByName("QUIActivityDialogDivination_AwardsTips", self:checkAwardsRedTips())
			end
			if data.divinationDivineResponse.normalRank then
				self._curServerRank = data.divinationDivineResponse.normalRank
			end
			if data.divinationDivineResponse.centerRank then
				self._allServerRank = data.divinationDivineResponse.centerRank
			end
			if data.divinationDivineResponse.divinationScore then
				self._curScore = data.divinationDivineResponse.divinationScore
				remote.redTips:setTipsStateByName("QUIActivityDialogDivination_ScoreTips", self:checkScoreRedTips())
			end
		end
		if success then
			success(data)
		end
    end, fail)
end

function QActivityDivination:requestDivinationGetReward(ty, value,success, fail)
	-- body
	local divinationGetAwardRequest = { type = ty, value = value}
	local request = {api = "DIVINATION_GET_AWARD", divinationGetAwardRequest = divinationGetAwardRequest}
    app:getClient():requestPackageHandler("DIVINATION_GET_AWARD", request, function(data)
    	if data.divinationGetAwardResponse and data.divinationGetAwardResponse.divinationInfo and data.divinationGetAwardResponse.divinationInfo.awards then
			self._awardInfo = data.divinationGetAwardResponse.divinationInfo.awards
			remote.redTips:setTipsStateByName("QUIActivityDialogDivination_AwardsTips", self:checkAwardsRedTips())
		end
		
		if data.divinationGetAwardResponse.normalRank then
			self._curServerRank = data.divinationGetAwardResponse.normalRank
		end
		if data.divinationGetAwardResponse.centerRank then
			self._allServerRank = data.divinationGetAwardResponse.centerRank
		end

		if success then
			success(data)
		end
    end, fail)
end


function QActivityDivination:requestDivinationReset(success, fail)
	-- bod
	local request = {api = "DIVINATION_RESET"}
    app:getClient():requestPackageHandler("DIVINATION_RESET", request, function(data)
    	if data.divinationResetResponse and data.divinationResetResponse.divinationInfo and data.divinationResetResponse.divinationInfo.awards then
			self._awardInfo = data.divinationResetResponse.divinationInfo.awards
			remote.redTips:setTipsStateByName("QUIActivityDialogDivination_AwardsTips", self:checkAwardsRedTips())
		end
		if success then
			success(data)
		end
    end, fail)
end

function QActivityDivination:getScoreAwards( awardIndex ,success, fail)
	-- body
	local divinationGetScoreAwardRequest = {scoreAwardIndex = awardIndex}
	local request = {api = "DIVINATION_GET_SCORE_AWARD",divinationGetScoreAwardRequest = divinationGetScoreAwardRequest}
	app:getClient():requestPackageHandler("DIVINATION_GET_SCORE_AWARD", request, function ( data )
		-- body
		if data.divinationGetScoreAwardResponse and data.divinationGetScoreAwardResponse.divinationScoreReward then
			self._scoreRewards = data.divinationGetScoreAwardResponse.divinationScoreReward
			remote.redTips:setTipsStateByName("QUIActivityDialogDivination_ScoreTips", self:checkScoreRedTips())
		end
		if success then
			success(data)
		end
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE})
	end)

end


function QActivityDivination:getRankData( rankType, success, fail, status )
	-- body
	local typeStr 
	if rankType == 0 then
		typeStr = "ENV_RANK"
	else
		typeStr = "CENTER_RANK"
	end
	local divinationGetRankInfoRequest = {type = typeStr}
    local request = {api = "DIVINATION_GET_RANK_INFO", divinationGetRankInfoRequest = divinationGetRankInfoRequest}
    app:getClient():requestPackageHandler("DIVINATION_GET_RANK_INFO", request, success, fail)
end


return QActivityDivination