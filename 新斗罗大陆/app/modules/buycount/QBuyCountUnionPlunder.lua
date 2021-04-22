-- @Author: xurui
-- @Date:   2017-01-19 12:07:40
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-07-05 17:25:24
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountUnionPlunder = class("QBuyCountUnionPlunder", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountUnionPlunder:ctor(options)
	-- body
	self._typeName = "gh_ykz_ld_times"
	self._vipField = "gh_ykz_ld_times"
	self._unlockType = "UNLOCK_KF_YKZ"
end

function QBuyCountUnionPlunder:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.plunder:getBuyLootCnt()
	self._num = self._totalNum
end

function QBuyCountUnionPlunder:getDesc()
	return "购买后可增加一次掠夺次数"
end

function QBuyCountUnionPlunder:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountUnionPlunder:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountUnionPlunder:getReciveNum()
	return "次数 X 1"
end

function QBuyCountUnionPlunder:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountUnionPlunder:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountUnionPlunder:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountUnionPlunder:getRefreshDesc()
	return "每日可购买掠夺次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountUnionPlunder:alertVipBuy()
	app:vipAlert({title = "掠夺次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.STORM_ARENA_RESET_COUNT}, false)
end

function QBuyCountUnionPlunder:requestBuy(succes, fail)
	remote.plunder:plunderBuyLootCntRequest(function(data)
 		 remote.user:addPropNumForKey("todayUnionPlunderBuyCount")--记录极北之地购买攻击次数
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountUnionPlunder