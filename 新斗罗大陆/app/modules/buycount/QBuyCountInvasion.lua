-- @Author: xurui
-- @Date:   2017-01-19 17:20:21
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-07-05 17:24:30
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountInvasion = class("QBuyCountInvasion", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountInvasion:ctor(options)
	-- body
	self._typeName = "intrusion_times"
	self._vipField = "intrusion_token"
	self._unlockType = "UNLOCK_FORTRESS"
end

function QBuyCountInvasion:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.user.todayBuyIntrusionTokenCount or 0
	self._num = self._totalNum
end

function QBuyCountInvasion:getDesc()
	return "用少量钻石购买一次攻击次数"
end

function QBuyCountInvasion:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountInvasion:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountInvasion:getReciveNum()
	return "次数 X 1"
end

function QBuyCountInvasion:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountInvasion:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountInvasion:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountInvasion:getRefreshDesc()
	return "每日可购买攻击次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountInvasion:alertVipBuy()
	app:vipAlert({title = "魂兽入侵购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.INVASION_TOKEN_BUY_COUNT}, false)
end

function QBuyCountInvasion:requestBuy(succes, fail)
	remote.invasion:buyInvasionTokenRequest(function ()
        remote.user:addPropNumForKey("c_buyInvasionCount")
        remote.activity:updateLocalDataByType(539, 1)
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountInvasion