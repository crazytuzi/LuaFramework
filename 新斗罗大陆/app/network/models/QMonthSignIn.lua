--
-- zxs
-- 月度签到
-- 
local QBaseModel = import("...models.QBaseModel")
local QMonthSignIn = class("QMonthSignIn", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QMonthSignIn.MONTH_SINGIN_IS_DONE = "MONTH_SINGIN_IS_DONE"       		--当前奖奖励已签到
QMonthSignIn.MONTH_SINGIN_IS_READY = "MONTH_SINGIN_IS_READY"       		--当前奖奖励可签到
QMonthSignIn.MONTH_SINGIN_IS_READY_VIP = "MONTH_SINGIN_IS_READY_VIP" 	--当前奖奖励可签到VIP奖励
QMonthSignIn.MONTH_SINGIN_IS_PATCH = "MONTH_SINGIN_IS_PATCH"       		--当前奖奖励可补签
QMonthSignIn.MONTH_SINGIN_IS_NONE = "MONTH_SINGIN_IS_NONE"       		--当前奖奖励不能操作

QMonthSignIn.SINGIN_TOTAL_NONE = 0       				--未达到
QMonthSignIn.SINGIN_TOTAL_COMPLETE = 1     				--已达到
QMonthSignIn.SINGIN_TOTAL_RECEIVED = 2       			--已领取

QMonthSignIn.MONTH_SINGIN_MAIN_EVENT = "MONTH_SINGIN_MAIN_EVENT"		-- 配置信息
QMonthSignIn.MONTH_SINGIN_UPDATE_EVENT = "MONTH_SINGIN_UPDATE_EVENT"	-- 签到信息

QMonthSignIn.NEW_MONETH_SIGN_IN_TIME = 1582992000 -- 新版月度签到开始的时间：2020年3月1日00:00:00

function QMonthSignIn:ctor(options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._signInConfigDict = {}          	--本月签到奖励
	self._signInAwardsList = {}          	--本月签到奖励
	self._signInChestAwardsList = {}      	--本月签到宝箱奖励
	self._signInServerDataDict = {}         --服务端签到信息
end

function QMonthSignIn:didappear()
	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self,self._onTimeRefreshHandler))
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.VIP_RECHARGED, self.updateMonthSignInInfo, self)
end

function QMonthSignIn:disappear()
	if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.VIP_RECHARGED, self.updateMonthSignInInfo, self)
end

function QMonthSignIn:loginEnd()
	if self:checkMonthSignInIsOpen() then
		self:setSignInDataConfig()
		self:getMonthSignInInfoByServer()
	end
end

function QMonthSignIn:checkShopIdCanBeBuy(shopLimit)
	local serverData = self:getSignInServerInfo()
	local signInDay = serverData.index or 0
    local shopLimit = tonumber(shopLimit) or 0
    if signInDay >= shopLimit then
        return true
    else
        return false
    end
end

function QMonthSignIn:checkMonthSignInIsOpen()
	if not app.unlock:checkLock("CHECK_IN_YUEDU") then
		return false
	end
	-- 是否开服14天内
	if remote.activity:checkActivityIsInDays(0, 14) then
		return false
	end
	return true
end

function QMonthSignIn:isNewMonthSignInOpen()
	if self:checkMonthSignInIsOpen() then
		if q.serverTime() >= QMonthSignIn.NEW_MONETH_SIGN_IN_TIME then
			return true
		end
	end

	return false
end

function QMonthSignIn:updateMonthSignInInfo( ... )
	if self:checkMonthSignInIsOpen() then
		self:getMonthSignInInfoByServer()
	end
end

function QMonthSignIn:_onTimeRefreshHandler(event)
	if event.time == nil or event.time == 0 then
		if self:checkMonthSignInIsOpen() then
        	self:setSignInDataConfig()
        	self:getMonthSignInInfoByServer(function()
					self:dispatchEvent({name = QMonthSignIn.MONTH_SINGIN_MAIN_EVENT})
        		end)
        end
    end
end

function QMonthSignIn:getMonthSignInYearMonthKey()
	local time = q.date("*t", q.serverTime())
	
	if self._yearAndMonthKey and self._lastYear and self._lastMonth and self._lastYear == time.year and self._lastMonth == time.month then
		return self._yearAndMonthKey
	end

	local yearAndMonth = time.year.."_"..(time.month >= 10 and time.month or ("0"..time.month))

	self._lastYear = time.year
	self._lastMonth = time.month
	self._yearAndMonthKey = yearAndMonth
	
	return yearAndMonth
end

function QMonthSignIn:setSignInDataConfig()
	local yearAndMonth = self:getMonthSignInYearMonthKey()
	self._signInChestAwardsList = db:getMonthSignInChestAwards(yearAndMonth) or {}

	self._signInConfigDict = {}
	self._signInAwardsList = {}
	self._signInServerDataDict = {}
	local data = db:getMonthSignInAwards(yearAndMonth)
	if data then
		self._signInConfigDict.avatar = data.avatar
		self._signInConfigDict.month = data.month
		self._signInConfigDict.theme = data.theme
		self._signInConfigDict.txt = data.txt

		local index = 1
		while data["type_"..index] do
			local itemType = data["type_"..index]
			if tonumber(data["type_"..index]) == nil then
				itemType = remote.items:getItemType(data["type_"..index])
			end
			local award ={id = data["id_"..index], itemType = itemType, count = data["num_"..index], day = index, vipLevel = data["vip_"..index], effect = data["effect_"..index]}
			self._signInAwardsList[index] = award
			index = index + 1
		end
	end
end

function QMonthSignIn:updateMonthSignInAwardByServerData()
	local serverData = self._signInServerDataDict

	local checkTime = function(time1, time2)
		if time1.year == time2.year and time1.month == time2.month and time1.day == time2.day then
			return true
		end
		return false
	end

	local gridList = serverData.gridList or {}
	table.sort(gridList, function(a, b)
			return a.gridId < b.gridId
		end)

	local currentTime = q.date("*t", q.serverTime())
	local lastSignInTime = q.date("*t", (serverData.last_checkin_at or 0)/1000)
	local signIndex = serverData.index or 0
	local signTimes = serverData.checkin_times or 0
	local isReadVip = false
	for _, value in ipairs(self._signInAwardsList) do
		local gridInfo = gridList[value.day] or {}
		local currentGridSignTime = q.date("*t", (gridInfo.lastCheckInAt or 0)/1000)

		value.stated = QMonthSignIn.MONTH_SINGIN_IS_NONE 
		if signIndex > value.day then
			if value.vipLevel and gridInfo.isCheck == true and gridInfo.isDoubleCheck == false and checkTime(currentTime, currentGridSignTime) then
				value.stated = QMonthSignIn.MONTH_SINGIN_IS_READY_VIP
			else
				value.stated = QMonthSignIn.MONTH_SINGIN_IS_DONE
			end
		elseif signIndex == value.day then
			if value.vipLevel and gridInfo.isCheck == true and gridInfo.isDoubleCheck == false and checkTime(currentTime, currentGridSignTime) then
				value.stated = QMonthSignIn.MONTH_SINGIN_IS_READY_VIP
			else
				value.stated = QMonthSignIn.MONTH_SINGIN_IS_DONE
			end
		elseif signIndex + 1 == value.day then
			if checkTime(currentTime, lastSignInTime) then --检查今天是否签到
				if signIndex < currentTime.day then
					value.stated = QMonthSignIn.MONTH_SINGIN_IS_PATCH
				end
			else
				if gridInfo.isCheck ~= true then
					value.stated = QMonthSignIn.MONTH_SINGIN_IS_READY
				elseif value.vipLevel and gridInfo.isDoubleCheck ~= true and checkTime(currentTime, currentGridSignTime) then
					value.stated = QMonthSignIn.MONTH_SINGIN_IS_READY_VIP
				end
			end
		end
	end
end

-- stated: 0，表示未激活；1，表示可领取；2，表示已领取
function QMonthSignIn:updateMonthSignChestByServerData()
	local serverData = self._signInServerDataDict
	local recivedList = string.split((serverData.addup_award or ""), ",")

	local checkIsRecived = function(times)
		local isRecived = false
		for _, value in ipairs(recivedList) do
			if times == tonumber(value) then
				isRecived = true
				break
			end
		end
		return isRecived
	end

	local maxDay = self:getCurrentMonthTotalDay()
	for _, value in ipairs(self._signInChestAwardsList) do
		local times = value.times
		if times == "max" then
			times = maxDay
		else
			times = tonumber(times)
		end
		if (serverData.index or 0) >= times then
			local isRecived = checkIsRecived(times)
			if isRecived then
				value.stated = QMonthSignIn.SINGIN_TOTAL_RECEIVED
			else
				value.stated = QMonthSignIn.SINGIN_TOTAL_COMPLETE
			end
		else
			value.stated = QMonthSignIn.SINGIN_TOTAL_NONE
		end
	end
end

function QMonthSignIn:getCurrentMonthTotalDay( ... )
	if not self._signInConfigDict.month then
		return 1
	end
	local time = string.split(self._signInConfigDict.month, "_")
	time = q.date("*t", q.getTimeForYMDHMS(tonumber(time[1]), tonumber(time[2])+1, 0, 0, 0, 0))

	return time.day
end

function QMonthSignIn:getCurrentPatchNum()
	local serverData = self._signInServerDataDict
	local patchNum = (serverData.total_supply or 0) - (serverData.cur_supply or 0)

	return patchNum
end

function QMonthSignIn:getCanPatchSignInNum()
	local serverData = self._signInServerDataDict
	local currentTime = q.date("*t", q.serverTime())
	local canPatchNum = currentTime.day - (serverData.index or 0)

	return canPatchNum
end

function QMonthSignIn:getSignInConfigInfo()
	return self._signInConfigDict
end

function QMonthSignIn:getSignInAwardList()
	return self._signInAwardsList
end

function QMonthSignIn:getSignInChestAwardList()
	return self._signInChestAwardsList
end

function QMonthSignIn:openDialog()
	self:getMonthSignInInfoByServer(function()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthSignIn"})
	end)
end

function QMonthSignIn:checkMonthSignInRedTips()
	if self:checkMonthSignInIsOpen() == false then
		return false
	end

	if self:checkSignInRedTip() then
		return true
	end

	if self:checkSignInChestRedTip() then
		return true
	end

	return false
end

function QMonthSignIn:checkSignInRedTip()		
	local patchNum = 0
	if self._signInServerDataDict then
		patchNum = self:getCurrentPatchNum()
	end
	for _, value in ipairs(self._signInAwardsList) do
		if  value.stated == self.MONTH_SINGIN_IS_READY or value.stated == self.MONTH_SINGIN_IS_READY_VIP or
			value.stated == self.MONTH_SINGIN_IS_PATCH and patchNum > 0 then
			return true
		end
	end

	return false
end

function QMonthSignIn:checkSignInChestRedTip( ... )
	for _, value in ipairs(self._signInChestAwardsList) do
		if value.stated == QMonthSignIn.SINGIN_TOTAL_COMPLETE then
			return true
		end
	end

	return false
end

--[[
message CheckInMonthInfo {
    optional int32 index           = 1;         // 签到第几次
    optional int32 checkin_times   = 2;         // 今天签到次数
    optional int64 last_checkin_at = 3;         // 最后签到时间
    optional int32 addup_count     = 4;         // 累计签到次数
    optional int32 addup_award     = 5;         // 领取累计奖次数
    optional int32 total_supply    = 6;         // 累计补签次数
    optional int32 cur_supply      = 7;         // 当前补签次数
    optional int64 last_supply_at  = 8;         // 上次补签时间
    repeated CheckInGrid gridList  = 9;         // 某月每天的签到信息
}
message CheckInGrid {
    optional int32 gridId = 1;                                              // 当月的第几天的签到
    optional bool isCheck = 2;                                              // 是否已签到
    optional bool isDoubleCheck = 3;                                        // 是否已双倍签到
    optional int64 lastCheckInAt = 4;                                       // 当前CheckInGrid的最近一次签到时间
}
]]
function QMonthSignIn:getSignInServerInfo()
	return self._signInServerDataDict
end

-------------------------- request event ----------------------------

function QMonthSignIn:monthResponseHandler(response, success, fail, succeeded)
	if response.checkInResponse and response.checkInResponse.checkInMonth then
		local data = response.checkInResponse.checkInMonth or {}
		for key, value in pairs(data) do
			self._signInServerDataDict[key] = value
		end
	end
		
	self:updateMonthSignInAwardByServerData()

	self:updateMonthSignChestByServerData()

	self:dispatchEvent({name = QMonthSignIn.MONTH_SINGIN_UPDATE_EVENT})

	self:responseHandler(self, response, success, fail, succeeded)
end

--[[
	签到信息request
]]
function QMonthSignIn:getMonthSignInInfoByServer(success, fail)
	local request = {api = "GET_CHECK_IN_MONTH_INFO"}
	app:getClient():requestPackageHandler(request.api, request, function(response)
			self:monthResponseHandler(response, success, nil, true)
		end,
		function(response)
			self:monthResponseHandler(response, nil, fail, nil)
		end)
end

--[[
	签到request
]]
function QMonthSignIn:requestMonthSignIn(index, success, fail)
	local checkInMonthRequest = {index = index}
	local request = {api = "CHECK_IN_MONTH", checkInMonthRequest = checkInMonthRequest}
	app:getClient():requestPackageHandler(request.api, request, function(response)
			self:monthResponseHandler(response, success, nil, true)
		end,
		function(response)
			self:monthResponseHandler(response, nil, fail, nil)
		end)
end

--[[
	宝箱奖励request
]]
function QMonthSignIn:requestMonthSignInChest(index, success, fail)
	local checkInAwardMonthRequest = {index = index}
	local request = {api = "CHECK_IN_AWARD_MONTH", checkInAwardMonthRequest = checkInAwardMonthRequest}
	app:getClient():requestPackageHandler(request.api, request, function(response)
			self:monthResponseHandler(response, success, nil, true)
		end,
		function(response)
			self:monthResponseHandler(response, nil, fail, nil)
		end)
end

return QMonthSignIn