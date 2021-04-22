
-- @Author: liaoxianbo
-- @Date:   2019-05-31 12:04:05
-- @Last Modified by:   Kai Wang
-- @Last Modified time: 2019-11-11 16:25:58

local QBaseModel = import("..models.QBaseModel")
local QActivityCrystal = class("QActivityCrystal",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import(".QVIPUtil")
local QLogFile = import("..utils.QLogFile")
local QActivity = import(".QActivity")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")

QActivityCrystal.EVENT_RECHARGE = "EVENT_RECHARGE"
QActivityCrystal.EVENT_GET_USER_DAILY_GIFT_INFO = "EVENT_GET_USER_DAILY_GIFT_INFO"

function QActivityCrystal:ctor( )
    QActivityCrystal.super.ctor(self)
    cc.GameObject.extend(self)
    self._giftRechargeInfo = {}
    self._giftReceiveInfo = {}
    self._autoGetGiftEndAt = 0
    self._autoGetGiftStartTime = 0
    self._autoNewAutoPay = false
end

function QActivityCrystal:loginEnd()
	self:requestGetCrystalGiftState(function(data)

	end)
end

function QActivityCrystal:getIsOpenCrystalShop()
	-- if app:getOpgameID() == '3001' then
	-- 	return false
	-- else
	-- 	return true
	-- end
	return true
end

function QActivityCrystal:updateRecord(userDailyGiftInfo)
	if not userDailyGiftInfo then return end
	local giftProgress = userDailyGiftInfo.giftProgress or ""
	local giftComplete = userDailyGiftInfo.giftComplete or ""
	self._giftRechargeInfo = string.split(giftProgress,";")
	self._giftReceiveInfo = string.split(giftComplete,";")
	self._autoGetGiftEndAt = userDailyGiftInfo.autoGetGiftEndAt or 0
end

function QActivityCrystal:getGiftRechargeInfo( )
	return self._giftRechargeInfo
end

function QActivityCrystal:getGiftReceiveInfo( )
	return self._giftReceiveInfo
end

function QActivityCrystal:checkMainCrystalShopRedTips( ... )
	
end
function QActivityCrystal:getAutoGetGiftUntilDay()
	local endTime = self._autoGetGiftEndAt / 1000
	local crystalGiftDurationDay = db:getConfigurationValue("crystalGift_durationDay") or 0
	local startTime = endTime - crystalGiftDurationDay * DAY
	local nowTime = q.serverTime()
	local lastDay = 0
	if nowTime >= startTime and nowTime < endTime then
		lastDay = math.ceil((endTime - nowTime) / DAY)
	elseif nowTime < startTime then
		lastDay = crystalGiftDurationDay + 1 
	end

	return lastDay
end

function QActivityCrystal:setNewTurnAutoPay( autoPayFlag )
	self._autoNewAutoPay = autoPayFlag
end

function QActivityCrystal:getNewTurnAutoPay()

	return self._autoNewAutoPay

end
-- 检测豪华签到是否激活 
function QActivityCrystal:checkTodayIsActivity()

	local cryStalendTime = self._autoGetGiftEndAt / 1000
	local crystalGiftDurationDay = db:getConfigurationValue("crystalGift_durationDay") or 0
	local cryStalstartTime = cryStalendTime - crystalGiftDurationDay * DAY
	local nowTime = q.serverTime()
	print("cryStalendTime=",cryStalendTime)
	print("cryStalstartTime=",cryStalstartTime)
	if cryStalstartTime <= nowTime and nowTime <= cryStalendTime then
		return true
	else
		return false
	end

	return false
end
function QActivityCrystal:checkGiftRechargeStateById( id )
	if next(self._giftRechargeInfo) == nil then return false end
	for _,v in pairs(self._giftRechargeInfo) do
		if tonumber(v) == id then
			return true
		end
	end

	return false
end

function QActivityCrystal:checkGiftReciveStateById( id )
	if next(self._giftReceiveInfo) == nil then return false end
	for _,v in pairs(self._giftReceiveInfo) do
		if tonumber(v) == id then
			return true
		end
	end

	return false
end

function QActivityCrystal:didappear()
    
end

function QActivityCrystal:disappear()

end

function QActivityCrystal:updateRechargeData(value)
	QLogFile:info(function ( ... )
        return string.format("QActivityCrystal:updateRechargeData value: %d. ", value)
    end)
    if value >= 6 then
		self:setNewTurnAutoPay(true)
	end
    self:dispatchEvent({name = QActivityCrystal.EVENT_RECHARGE,value = value})	
end

function QActivityCrystal:checkCrystalRedtips()

	if self:checkCrystalShopRedTips() then
		return true
	end

	self._allCrygifts = db:getCrystalGift() or {}
	local day = self:getAutoGetGiftUntilDay()
	for _,v in pairs(self._allCrygifts) do
		local rechargeState = self:checkGiftRechargeStateById(v.gifts_id)
		local reciveState = self:checkGiftReciveStateById(v.gifts_id)

		if v.prize == 0 and not reciveState then
			return true
		end
		if day > 0 and day < 8 and not reciveState then
			return true
		elseif rechargeState and not reciveState then
			return true
		end
	end
	return false
end

function QActivityCrystal:checkCrystalShopRedTips()  
    local limtCrystalPiece = db:getConfigurationValue("crystal_beyond") or 0
    local myCrystalPiece = remote.user.crystalPiece or 0
    if myCrystalPiece > 0 and myCrystalPiece > limtCrystalPiece then
    	return app:getUserOperateRecord():compareCurrentTimeWithRecordeTime("activity_cryStalShop")
    else
    	return false
    end
end

-- message UserDailyGiftInfo{
--     optional string giftProgress = 1;          // 礼包充值情况 量表id和进度  1;2;  充值了第一个和第二个
--     optional string giftComplete = 2;          // 礼包领取情况 量表id和进度  1;2;  领取了第一个和第二个
--     optional int64 autoGetGiftEndAt = 3;       // 不用充值即可领取结束时间
-- }

-----------------request--------------------------
-- 每日礼包状态获取
function QActivityCrystal:requestGetCrystalGiftState(success, fail)
    local request = {api = "GET_USER_DAILY_GIFT_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function(data)
    		self:updateRecord(data.userDailyGiftInfo)
            self:dispatchEvent({name = QActivityCrystal.EVENT_GET_USER_DAILY_GIFT_INFO})
            if success then
                success(data)
            end
        end, fail)
end
--每日礼包领取
function QActivityCrystal:requestMyCryStalShopDailyGift(id,success, fail)
	local userDailyGiftCompleteRequest = {id = id}
    local request = {api = "COMPLETE_USER_DAILY_GIFT",userDailyGiftCompleteRequest = userDailyGiftCompleteRequest}
    app:getClient():requestPackageHandler(request.api, request, function(data)
    		self:updateRecord(data.userDailyGiftInfo)
            if success then
                success(data)
            end
        end, fail)
end

return QActivityCrystal