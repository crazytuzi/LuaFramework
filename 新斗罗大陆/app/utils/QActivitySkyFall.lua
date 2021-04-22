-- @Author: DELL
-- @Date:   2020-03-27 10:56:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-04-09 17:52:40

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivitySkyFall = class("QActivitySkyFall",QActivityRoundsBaseChild)

local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import(".QVIPUtil")
local QActivity = import(".QActivity")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")

function QActivitySkyFall:ctor(luckType)
    QActivitySkyFall.super.ctor(self,luckType)
    cc.GameObject.extend(self)

    self._everyDaySkyFallTimes = 0	--今日已打开红包次数
    self._activitySkyfallInfo = {}	--活动信息
    self._totaleTokenNums = 0		--钻石累计获取
    self._rankAwardsInfo = {}		-- 前三名奖励信息
    self._curRoundAwards = {}		--当前活动轮次累计奖励
    self._maxCondion = 0

end

function QActivitySkyFall:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.SKY_FALL_UPDATE})
	end
end

function QActivitySkyFall:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.SKY_FALL_UPDATE})
end

function QActivitySkyFall:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.SKY_FALL_UPDATE})
end

function QActivitySkyFall:handleOnLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.SKY_FALL_UPDATE})
end

function QActivitySkyFall:handleOffLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.SKY_FALL_UPDATE})
end

function QActivitySkyFall:getActivityInfoWhenLogin( success, fail )
	self:initCurRoundAwards()
    self:requestMySkyFallInfo(success, fail)
end

function QActivitySkyFall:initCurRoundAwards()
	if not self.rowNum then
		return
	end
	local scoreRewards = db:getSkyFallScoreRewardByRowNum(self.rowNum)
	table.sort( scoreRewards, function(a,b)
		if a.condition ~= b.condition then
			return a.condition < b.condition
		end
	end )
	for _,v in pairs(scoreRewards) do
		self._maxCondion = math.max(self._maxCondion,v.condition)
	end
	self._curRoundAwards = scoreRewards
end


function QActivitySkyFall:checkSkyFallIsOpen()
	if not app.unlock:checkLock("UNLOCK_SKY_FALL",false) then
		return false
	end
	return self.isOpen
end

function QActivitySkyFall:checkCanOpen()
    local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
    if ((nowDateTable.hour == 23 and nowDateTable.min == 59 and nowDateTable.sec > 55) or (nowDateTable.hour == 0 and nowDateTable.min <= 5)) 
    	and self.showEndAt - q.serverTime() > DAY and q.serverTime() - self.startAt > DAY then
        return false
    end
    return true
end

function QActivitySkyFall:checkRedTips()
	if not self:checkSkyFallIsOpen() then
		return false
	end
	
	if q.isEmpty(self._activitySkyfallInfo) then
		return false
	end

	if not self:checkCanOpen() then
		return false
	end
	-- 有累积钻石奖励可以领取
	local function getIsGetAward(id)
		for i, v in pairs(self._activitySkyfallInfo.getScoreIdList or {}) do
			if tonumber(v) == id then
				return true
			end
		end
		return false
	end	
	local totalGetToken = (self._activitySkyfallInfo.totalGetToken or 0)
	for i, v in pairs(self._curRoundAwards) do
		if not getIsGetAward(v.id) and totalGetToken > v.condition then
			return true
		end
	end

	if self.showEndAt - q.serverTime() < DAY then
		return false
	else
		return self:getLastSkyFallTimes() > 0
	end

end

function QActivitySkyFall:openDialog()
	if not self:checkSkyFallIsOpen() then
		return
	end
	if not self:checkCanOpen() then
		app.tip:floatTip("天降红包结算中，无法领取")
		return
	end
	self:requestMySkyFallInfo(function( )
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySkyFall"})
	end)	
end

function QActivitySkyFall:getLastSkyFallTimes()
	local maxTimes = db:getConfigurationValue("SKY_FALL_LIMIT_CHANCE")


	return maxTimes - self._everyDaySkyFallTimes
end

function QActivitySkyFall:getTotaleTokenNums()
	return self._totaleTokenNums
end

function QActivitySkyFall:getRankAwardsInfo( )
	return self._rankAwardsInfo
end

function QActivitySkyFall:getCurRoundAwards( )
	return self._curRoundAwards,self._maxCondion
end

function QActivitySkyFall:getRandomRedpackage()
	if q.isEmpty(self._activitySkyfallInfo) then
		return {}
	end
	local randomPackage = {}
	for key,packageInfo in pairs(self._activitySkyfallInfo.packageInfoList or {}) do
		randomPackage[key] = packageInfo
	end
	return randomPackage
end

function QActivitySkyFall:getActivitySkyFallInfo()
	return self._activitySkyfallInfo
end

function QActivitySkyFall:updateMySkyFallInfo( data)
	self._activitySkyfallInfo = data.userSkyFallInfoResponse or {}
	self:updateGetRedPackageTimes()
end

function QActivitySkyFall:updateGetRedPackageTimes()

	if q.isEmpty(self._activitySkyfallInfo) then
		return
	end
	local getPackageIdList = self._activitySkyfallInfo.getPackageIdList or {}

	self._rankAwardsInfo = self._activitySkyfallInfo.infoList or {}

	self._everyDaySkyFallTimes = #getPackageIdList

end
-------------------数据转换-------------------------------

function QActivitySkyFall:switchLuckAwards(awards,tbl)
	if tbl == nil then tbl = {} end
	if awards == nil or awards == "" then
		return tbl
	end
    local record = string.split(awards,";")
    for _,value in pairs(record) do
        if value and value ~= "" then
            local s, e = string.find(value, ",")
            local rankNum = string.sub(value, 1, s - 1)
            local itemStr = string.sub(value, e + 1)
            if itemStr and itemStr ~= "" then
            	local tblStr = string.split(itemStr,"^")
            	local itemId = tblStr[1]
            	local count = tblStr[2]

            	tbl[tonumber(rankNum)] = {rankNum = rankNum, itemId = itemId,count = count }
            end
        end
    end	

    return tbl
end

-----------------request--------------------------
function QActivitySkyFall:responseHandler( response, successFunc, failFunc )

	self:updateMySkyFallInfo(response)

    if successFunc then 
        successFunc(response) 
        return
    end

    if failFunc then 
        failFunc(response)
    end
end

function QActivitySkyFall:requestMySkyFallInfo( success, fail, status )
    local request = { api = "SKY_FALL_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler("SKY_FALL_GET_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--打开红包
function QActivitySkyFall:playerOpenRedPackageRequest(idList,success, fail, status)
    local request = { api = "SKY_FALL_GET_RED_PACKAGE_REWARD",skyFallActivityOpenRedPackageRequest = {idList = idList}}
    app:getClient():requestPackageHandler("SKY_FALL_GET_RED_PACKAGE_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获得累计奖励
function QActivitySkyFall:playerGetSocreAwardsRequest(idList,success, fail, status)
    local request = { api = "SKY_FALL_GET_SCORE_REWARD",skyFallActivityGetScoreRewardRequest = {idList = idList}}
    app:getClient():requestPackageHandler("SKY_FALL_GET_SCORE_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QActivitySkyFall