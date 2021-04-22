-- @Author: vicentboo
-- @Date:   2019-07-08 10:25:00
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-28 17:02:23

local QBaseModel = import("..models.QBaseModel")
local QGradePackage = class("QGradePackage",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import(".QVIPUtil")
local QActivity = import(".QActivity")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QLogFile = import("..utils.QLogFile")

QGradePackage.EVENT_RECHARGE = "EVENT_RECHARGE"

function QGradePackage:ctor( )
    QGradePackage.super.ctor(self)
    cc.GameObject.extend(self)

    self._gradePackageList = {}
    self._historyRewardsInfo = {}
    self._allBtnList = {}
end

function QGradePackage:didappear()
end

function QGradePackage:disappear()
    self._gradePackageList = {}
    self._historyRewardsInfo = {}
    self._allBtnList = {}
end

function QGradePackage:loginEnd(callback)
	local levelRward = clone(db:getStaticByName("level_reward"))
	for _,v in pairs(levelRward) do
		v.received = 2
		v.haveExchangeNum = v.exchange_num
		if not self._gradePackageList[v.level] then
			self._gradePackageList[v.level] = {}
			table.insert(self._allBtnList,v.level)
		end
		table.insert(self._gradePackageList[v.level],v)
	end
	table.sort(self._allBtnList, function( a,b )
		return a < b
	end )

	self:requestHistoryGradePackage(function(data)
		self:setUserGradePackageInfo(data.userLevelRewards)
		if callback then
			callback()
		end
	end, callback)
end


function QGradePackage:switchGradePakgeReward(rewards)
	local historyReward = {}
    if rewards then
        local record = string.split(rewards,";")
        for _,value in pairs(record) do
            if value and value ~= "" then
                local s, e = string.find(value, "%^")
                local id = string.sub(value, 1, s - 1)
                local count = string.sub(value, e + 1)
                table.insert(historyReward,{id = tonumber(id),count = tonumber(count) })
            end
        end
    end
    return historyReward
end

function QGradePackage:checkGradePackageIsOpen()
	-- if device.platform == "ios" and (not FinalSDK.isHXIOS()) then
	-- 	return false
	-- else
	-- 	return true
	-- end
	return true
end
function QGradePackage:getGradePackageUntilTime()
	local untilTIme = QStaticDatabase:sharedDatabase():getConfigurationValue("LEVEL_REWARD_TIME_OUT_HOUR")
	if untilTIme then
		return tonumber(untilTIme)
	else
		-- 没有配表的测试时间
		return 3.17
	end
end

function QGradePackage:setUserGradePackageInfo(levelRewards)
	if not levelRewards then return end
	for _,history in pairs(levelRewards) do
		if not self._historyRewardsInfo[history.level] then
			self._historyRewardsInfo[history.level] = {}
		end

		self._historyRewardsInfo[history.level].level = history.level
		self._historyRewardsInfo[history.level].unlockRecharge = self:switchGradePakgeReward(history.unlockRecharge)
		self._historyRewardsInfo[history.level].drawInfo = self:switchGradePakgeReward(history.drawInfo)
		self._historyRewardsInfo[history.level].unlockTime = history.unlockTime
	end
	table.sort(self._historyRewardsInfo, function(a,b)
		return a.level > b.level
	end )
	self:updateGradePackageInfo()
end

function QGradePackage:updateGradePackageInfo()
	if next(self._historyRewardsInfo) == nil then return end
	for _,historyInfo in pairs(self._historyRewardsInfo) do
		if historyInfo.drawInfo and next(historyInfo.drawInfo) ~= nil and self._gradePackageList[historyInfo.level] then
			for _,draw in pairs(historyInfo.drawInfo) do
				for _,vlue in pairs(self._gradePackageList[historyInfo.level]) do
					if draw.id == vlue.id then
						vlue.haveExchangeNum = tonumber(vlue.exchange_num) - (tonumber(draw.count) or 0)
						if tonumber(draw.count) >= tonumber(vlue.exchange_num) then
							vlue.received = 1 --已领取
						end
					end
				end
			end
		end
		if historyInfo.unlockRecharge and next(historyInfo.unlockRecharge) ~= nil and self._gradePackageList[historyInfo.level] then
			for _,draw in pairs(historyInfo.unlockRecharge) do
				for _,vlue in pairs(self._gradePackageList[historyInfo.level]) do
					if draw.id == vlue.id then
						vlue.recharged = 1 --已领取
					end
				end
			end
		end		
	end

end

function QGradePackage:getHistoryGradePackageInfoByLevel(level)
	return self._historyRewardsInfo[level]
end


function QGradePackage:openDialog()
	
	self:requestHistoryGradePackage(function(data)
		self:setUserGradePackageInfo(data.userLevelRewards)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGradePackage"})
	end)	
	
end

function QGradePackage:updateRechargeData(value,itemId)
	if itemId then
		QLogFile:info(function ( ... )
	        return string.format("QGradePackage:updateRechargeData value: %d. itemId %d", value,itemId)
	    end)

	    self:dispatchEvent({name = QGradePackage.EVENT_RECHARGE,itemId = itemId})	
	end	
end

function QGradePackage:getGradePackageInfo()
	local btnList = {}
	local index = 0
	for _,btn in pairs(self._allBtnList) do
		local v = self._gradePackageList[btn]
		if next(v) ~= nil then
			if self._historyRewardsInfo[v[1].level] then
				local isOvertime, timeStr, color = self:updateTime(self._historyRewardsInfo[v[1].level].unlockTime)
				if not isOvertime then
					table.insert(btnList, {type = v[1].name, btnLimtLevel = v[1].level, title = v[1].name,unlockTime = self._historyRewardsInfo[v[1].level].unlockTime})
				end
			elseif v[1].level > remote.user.level and index < 3 then
				index = index + 1
				table.insert(btnList, {type = v[1].name, btnLimtLevel = v[1].level, title = v[1].name})
			end
		end
	end

	table.sort( btnList, function( a,b )
		return a.btnLimtLevel < b.btnLimtLevel
	end )

	return btnList
end

function QGradePackage:getContentListByKey(btnLimtLevel)
	local btnGradePackageList = self._gradePackageList[btnLimtLevel]
	table.sort( btnGradePackageList, function(a,b)
		
		if a.received ~= b.received then
			return a.received > b.received
		else
			return a.type < b.type
		end
	
	end )
	return btnGradePackageList
end

function QGradePackage:checkGradePakgeShowToPageMain()
	local lastTime = 0
	local isShow = false

	if not self:checkGradePackageIsOpen() then
		return isShow,lastTime
	end

	if next(self._historyRewardsInfo) ~= nil then
		for _,history in pairs(self._historyRewardsInfo) do
			local endTime = history.unlockTime + self:getGradePackageUntilTime()*HOUR*1000
			local nowTime = q.serverTime() * 1000

			if nowTime >= endTime then
				break
			else
				isShow = true
				lastTime = math.max(lastTime,history.unlockTime)
			end
		end
	end

	return isShow,lastTime
end

function QGradePackage:checkGradePakgePageMainRedTips()
	for index,v in pairs(self._gradePackageList) do
		if next(v) ~= nil then
			if self._historyRewardsInfo[v[1].level] then
				for _,packageInfo in pairs(v) do
					if packageInfo.received and packageInfo.received == 2 and packageInfo.type == 1 then
						return true
					end
				end
			end
		end
	end

	return false
end

function QGradePackage:checkGradePakgeBtnRedTips(btnLevel)
	local btnInfo = self:getContentListByKey(btnLevel)
	if btnInfo and next(btnInfo) ~= nil then
		if self._historyRewardsInfo[btnLevel] then
			for _,packageInfo in pairs(btnInfo) do
				if packageInfo.received and packageInfo.received == 2 and packageInfo.type == 1 then
					return true
				end
			end
		end 
	end

	return false
end
-- 倒计时
function QGradePackage:updateTime(startTime)
	local isOvertime = false
	local untilTIme = self:getGradePackageUntilTime()
	local endTime = startTime + HOUR*untilTIme*1000
	local nowTime = q.serverTime() * 1000
	local timeStr = ""
	local color = COLORS.m -- 红色
	if nowTime >= endTime then
		isOvertime = true
	else
		local sec = (endTime - nowTime)/1000
		if sec >= 30*60 then
			color = ccc3(204, 135, 109)
		else
			color = COLORS.m
		end
		local h, m, s = self:_formatSecTime( sec )
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
	end

	return isOvertime, timeStr, color
end

function QGradePackage:_formatSecTime( sec )
	local h = math.floor((sec/HOUR))
	local m = math.floor((sec/MIN)%MIN)
	local s = math.floor(sec%MIN)

	return h, m, s
end
-----------------request--------------------------
--拉去礼包记录
function QGradePackage:requestHistoryGradePackage(success,fail)
	local request = {api = "USER_LEVEL_REWARD_GET_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
            if success then
                success(response)
            end
    end, fail)	
end

--礼包领取,购买，兑换
function QGradePackage:requestGetGradePackage(id,num,success, fail)
	local userLevelRewardComleteRequest = {id = id,num = num}
	local request = {api = "USER_LEVEL_REWARD_COMLETE", userLevelRewardComleteRequest = userLevelRewardComleteRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    		self:setUserGradePackageInfo(response.userLevelRewards)
            if success then
                success(response)
            end
    end, fail)	
end

return QGradePackage