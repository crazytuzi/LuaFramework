
local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityTurntable = class("QActivityTurntable",QActivityRoundsBaseChild)
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QActivityTurntable:ctor( ... )
	-- body
	QActivityTurntable.super.ctor(self,...)
	self._activityData = {}
end

function QActivityTurntable:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then
		self._activityData.lastFreeDrawAt = 0
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
	end
end

function QActivityTurntable:checkRedTips(  )
	-- body
	local data = self:getData()
	if data.isFree and self.isActivityNotEnd then
		return true;
	end
	for k, v in pairs(data.boxData or {}) do
		if v.isLight then
			return true;
		end
	end
end

function QActivityTurntable:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
end

function QActivityTurntable:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
end

function QActivityTurntable:handleOnLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
end

function QActivityTurntable:handleOffLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
end

function QActivityTurntable:getData(  )
	-- body
	local data = {}
	if not self.isOpen then
		data.isOpen = false
		return data
	end
	data.isOpen = true
	local tavernInfo = QStaticDatabase:sharedDatabase():getTavernLuckyDraw()
	
	if (not self.rowNum) or (not tavernInfo[tostring(self.rowNum)]) then
		return data
	end

	local info = tavernInfo[tostring(self.rowNum)]
	
	data.startAt = self.startAt  or 0
	data.endAt = self.endAt or 0
	data.showEndAt = self.showEndAt or 0
	data.baseScore = tonumber(info.score) or 0
	data.boxData = {}
	data.theme = info.theme or ""
	data.centerItem = info.hero_name or ""
	data.itemshow = info.hero_show or ""
	data.rowNum = self.rowNum
	data.dungeon_monster_tips = info.dungeon_monster_tips

	for i = 1,10 do
		local temp = {}
		temp.score = tonumber(info[string.format("box%d_score", i)]) or 0
		temp.awards = {}
		local awards = string.split(info["box"..i] or "", ";") 
		local count = #awards
		for i=1,count,1 do
			local obj = string.split(awards[i], "^")
	        if #obj == 2 then
	        	local itemType = remote.items:getItemType(id)
	        	table.insert(temp.awards, {id = obj[1], typeName = itemType or ITEM_TYPE.ITEM,count = tonumber(obj[2])})
	        end
		end
		local isFind = false
		for k, v in pairs(self._activityData.awardedBoxIds or {}) do
			if v == i then
				isFind = true
				break;
			end
		end

		if isFind then
			temp.isOpened = true
		else
			temp.isOpened = false
		end

		if not temp.isOpened and (self._activityData.drawScore or 0) >= temp.score then
			temp.isLight = true
		else
			temp.isLight = false
		end
		table.insert(data.boxData, temp)
	end
	data.maxScore = data.boxData[10].score
	data.onePrice = info.one_price or 0
	data.tenPrice = info.ten_price or 0

	if self._activityData.lastFreeDrawAt then
		local date1 = q.date("*t", self._activityData.lastFreeDrawAt/1000)
		local date2 = q.date("*t", q.serverTime())

		if date1 and date2 and date1.day == date2.day then
			data.isFree = false
		else
			data.isFree = true
		end
	else
		data.isFree = true
	end

	data.commonRank = self._activityData.commonRank
	data.eliteRank = self._activityData.eliteRank
	data.curScore = self._activityData.drawScore

	return data
end

function QActivityTurntable:getRankScoreCondition(  )
	-- body
	local tavernInfo = QStaticDatabase:sharedDatabase():getTavernLuckyDraw()
	
	if (not self.rowNum) then
		return 
	end

	local info = tavernInfo[tostring(self.rowNum)]
	if (not info) then
		return 
	end
	return info.score_condition
end

function QActivityTurntable:getSpecialAwardRank(  )
	-- body
	if (not self.rowNum) then
		return 
	end
	local staticData = QStaticDatabase:sharedDatabase():getTurntableRankAwardByRowNum(self.rowNum) or {}
	local maxRank = 1
	
	for k, v in pairs(staticData) do
	
		if maxRank < v.rank_2 and v.super_list == 1 then
			maxRank = v.rank_2
		end
	end
	return maxRank
end



function QActivityTurntable:udpateMyRankInfo( isElite, rank )
	-- body
	if rank and rank > 0 then
		local isChange = false
		if isElite then
			isChange = rank ~= self._activityData.eliteRank
			self._activityData.eliteRank = rank
		else
			isChange = rank ~= self._activityData.commonRank
			self._activityData.commonRank = rank
		end
		if isChange then		
			remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
		end
	end
end

function QActivityTurntable:getCommonRank(  )
	-- body
	return self._activityData.commonRank or 0
end

function QActivityTurntable:getEliteRank(  )
	-- body
	return self._activityData.eliteRank or 0
end

function QActivityTurntable:getBoxAwards(boxId, success, fail, status)

    local luckyDrawIntegralFeedbackRequest = {boxId = boxId}
    local request = {api = "LUCKY_DRAW_INTEGRAL_FEEDBACK", luckyDrawIntegralFeedbackRequest = luckyDrawIntegralFeedbackRequest}
    app:getClient():requestPackageHandler("LUCKY_DRAW_INTEGRAL_FEEDBACK", request, success, fail)
end

function QActivityTurntable:buyItems(count, success, fail, status)
    local luckyDrawDirectionRequest = {count = count}
    local request = {api = "LUCKY_DRAW_DIRECTIONAL", luckyDrawDirectionRequest = luckyDrawDirectionRequest}
    app:getClient():requestPackageHandler("LUCKY_DRAW_DIRECTIONAL", request, success, fail)
end

function QActivityTurntable:getRankData( rankType, success, fail, status )
	-- body
	local luckyDrawDirectionalGetRanksRequest = {rankType = rankType}
    local request = {api = "LUCKY_DRAW_DIRECTIONAL_RANK", luckyDrawDirectionalGetRanksRequest = luckyDrawDirectionalGetRanksRequest}
    app:getClient():requestPackageHandler("LUCKY_DRAW_DIRECTIONAL_RANK", request, success, fail)
end


function QActivityTurntable:updateSelfInfo( data )
	-- body
	self._activityData = data
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.TURNTABLE_UPDATE})
end

function QActivityTurntable:getActivityInfo( success, fail )
	-- body
	local request = {api = "LUCKY_DRAW_DIRECTIONAL_GET_SELF_INFO"}
	local successCallBack = function ( data )
		if data.userLuckyDrawDirectionalInfo then
			self:updateSelfInfo(data.userLuckyDrawDirectionalInfo)
		end
		if success then
			success()
		end
	end
    app:getClient():requestPackageHandler("LUCKY_DRAW_DIRECTIONAL_GET_SELF_INFO", request, successCallBack, fail)
end


function QActivityTurntable:getActivityInfoWhenLogin( success, fail )
	-- body
	return self:getActivityInfo(success, fail)
end


return QActivityTurntable