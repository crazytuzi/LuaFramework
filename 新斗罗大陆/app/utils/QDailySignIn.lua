
local QBaseModel = import("..models.QBaseModel")
local QDailySignIn = class("QDailySignIn",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QVIPUtil = import("..utils.QVIPUtil")
local QNotificationCenter = import("..controllers.QNotificationCenter")

function QDailySignIn:ctor()
	QDailySignIn.super.ctor(self)
	self._checkIn = nil
	self._checkInAt = nil
	self._checkinTimesRes = nil
	self._addUpDailySignNum = nil
	self._addUpDailySignAward = nil

	self._deluxeCheckInfo ={}
end

function QDailySignIn:loginEnd()
	--登录结束后先拉一次豪华签到信息
	self:getDeluxeInfo()

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.VIP_RECHARGED, self.getDeluxeInfo, self)
end

function QDailySignIn:disappear() 
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.VIP_RECHARGED, self.getDeluxeInfo, self)
end

function QDailySignIn:getDeluxeInfo()
	self:deluxeCheckIn()
end

function QDailySignIn:updateComplete(checkin, checkinAt, checkinTimesRes)
	if checkin then
		self._checkIn = checkin
	end
	if checkinAt then
		self._checkInAt = checkinAt
	end
	if checkinTimesRes then
		self._checkinTimesRes = checkinTimesRes
	end
end

--更新累积签到次数
function QDailySignIn:updateAddUpSignInNum(addUpDailySignNum, addUpDailySignAward)
	if addUpDailySignNum ~= nil then
		self._addUpDailySignNum = addUpDailySignNum
	end
	if addUpDailySignAward ~= nil then
		self._addUpDailySignAward = addUpDailySignAward
	end
end

--更新累积签到信息
function QDailySignIn:updateDeluxeCheckInfo(info)
	if info ~= nil then
		self._deluxeCheckInfo = info
	end
end 

function QDailySignIn:getDailySignIn()
	return self._checkIn, self._checkInAt
end

function QDailySignIn:getCurrentSignInState()
	return self._checkinTimesRes or 0
end

function QDailySignIn:getAddUpSignIn()
	return self._addUpDailySignNum, self._addUpDailySignAward
end

function QDailySignIn:getDeluxeCheckInfo()
	return self._deluxeCheckInfo
end

--检查是否签到
function QDailySignIn:checkTodaySignIn()
	if self._checkInAt == nil or self._checkInAt == 0 then
		return false
	end
	local refreshTime = q.refreshTime(0)
	if self._checkInAt/1000 < refreshTime then
		return false
	end
	return true
end

function QDailySignIn:checkVipSignIn()
	local currTime = q.date("*t", q.serverTime())
	local month = 0
	if currTime["month"] < 10 then
		month = "0"..currTime["month"]
	else
		month = currTime["month"]
	end
	local reward = QStaticDatabase.sharedDatabase():getDailySignInItmeByMonth(currTime["year"].."_"..month)
	if self._checkinTimesRes == 1 and reward["vip_"..self._checkIn] ~= nil and reward["vip_"..self._checkIn] <= QVIPUtil:VIPLevel() then
		return false
	end
	return true
end

--检查是否可以领取签到奖励
function QDailySignIn:checkAddUpAward()
	if self._addUpDailySignNum ~= nil and self._addUpDailySignAward ~= nil then
		local signNum = self:getAddUpSignIn()
		local award = QStaticDatabase:sharedDatabase():getAddUpSignInItmeByMonth(self._addUpDailySignNum, self._addUpDailySignAward)
		if signNum >= award.times then
			return true
		end
	end
	return false
end

--重置签到次数
function QDailySignIn:checkSignTime()
	local offsetTime = (0 * 3600)
	local currTime = q.date("*t", q.serverTime() - offsetTime)
	local signInTime = q.date("*t", self._checkInAt/1000 - offsetTime)
	if signInTime and (currTime["month"] ~= signInTime["month"] or currTime["year"] ~= signInTime["year"]) then
		self._checkIn = 0
	end
end

--检查点到小红点
function QDailySignIn:checkRedTips()
	-- 每日签到
	if self:checkDailyRedTip() then
		return true
	end

	-- 累积签到
	if self:checkAddUpAward() then
		return true
	end

	--豪华签到
	if self:checkDeluxeRedTip() then
		return true
	end

	return false
end

function QDailySignIn:checkDailyRedTip()
	local signIn = self:checkTodaySignIn()
	if signIn == false or self:checkVipSignIn() == false then
		return true
	end
	return false
end

function QDailySignIn:checkDeluxeRedTip()
	if ENABLE_DELUXE_SIGNIN == false then
		return false
	end

	local deluxeInfo = self:getDeluxeCheckInfo()
	local tips = false

	local lastRefreshTime = app.tip.unlockTutorial.daily or 0
    local refershTime = q.getTimeForHMS("5", "00", "00")
    if q.serverTime() < refershTime then
    	refershTime = refershTime - (24 * 3600)
    end
    if deluxeInfo.info == nil then
    	app.tip:floatTip("豪华签到的数据为空，找客服妹妹解决一下。")
    	return false
    end

    if lastRefreshTime < refershTime or (deluxeInfo.info[1].isQualified and deluxeInfo.info[1].hasTaken == false) then
    	tips = true
    end

	return tips
end

--检查是否需要更新豪华签到信息
function QDailySignIn:checkNeedRefreshDeluxeInfo()
	local needRefresh = false
	local lastRefreshTime = self:getDeluxeCheckInfo().getInfoAt or 0
    local beforeTime = q.getTimeForHMS("5", "00", "00")+5
    if q.serverTime() < beforeTime then 
        beforeTime = beforeTime - 24 * 3600 
    end
    if lastRefreshTime < beforeTime then
        needRefresh = true
    end
    return needRefresh
end

-- 检查补签次数
function QDailySignIn:getPatchNum()
	local patchNum = 0
	local checkIn = self:getDailySignIn() or 0

	local offsetTime = 0 * 3600
	local createAt = q.date("*t", remote.user.userCreatedAt/1000-offsetTime)	
	local nowTime = q.date("*t", q.serverTime()-offsetTime)
	
	if createAt.month == nowTime.month and createAt.year == nowTime.year then
		patchNum = nowTime.day - (createAt.day - 1 + checkIn)
	else
		patchNum = nowTime.day - checkIn
	end
	if remote.daily:checkTodaySignIn() == false then
		patchNum = patchNum - 1
	end

	return patchNum
end


--------------------- request hanlder ------------------------

function QDailySignIn:updateCheckInfo(response, success)
	self:updateDeluxeCheckInfo(response.luxuriousCheckInInfo)
	self:updateAddUpSignInNum(response.addupCheckinCount, response.addupCheckinAward)

	if success ~= nil then
		success(response)
	end
end

function QDailySignIn:getDeluxeCheckInfoRequest(recharge, success, fail, status)
    local luxuriousCheckInRequest = {recharge = recharge}
    local request = {api = "LUXURIOUS_CHECK_IN", luxuriousCheckInRequest = luxuriousCheckInRequest}
    local successCallback = function (response)
    	self:updateCheckInfo(response, success)
    end
    app:getClient():requestPackageHandler("LUXURIOUS_CHECK_IN", request, successCallback, fail)
end

function QDailySignIn:deluxeCheckIn(success, fail, status)
    local request = {api = "GET_LUXURIOUS_CHECK_IN_INFO"}
    local successCallback = function (response)
    	self:updateCheckInfo(response, success)
    end
    app:getClient():requestPackageHandler("GET_LUXURIOUS_CHECK_IN_INFO", request, successCallback, fail)
end


return QDailySignIn