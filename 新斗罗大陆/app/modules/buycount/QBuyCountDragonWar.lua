-- @Author: xurui
-- @Date:   2017-03-03 15:13:00
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-07-05 17:24:12
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountDragonWar = class("QBuyCountDragonWar", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountDragonWar:ctor(options)
	-- body
	self._typeName = "sociaty_dragon_fight_times"
	self._vipField = "sociaty_dragon_fight_times"
	self._unlockType = "SOCIATY_DRAGON_FIGHT"
end

function QBuyCountDragonWar:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.unionDragonWar:getMyInfo().buyFightCount or 0
	self._num = self._totalNum
end

function QBuyCountDragonWar:getDesc()
	return "用少量钻石购买挑战次数"
end

function QBuyCountDragonWar:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountDragonWar:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountDragonWar:getReciveNum()
	return "次数 X 1"
end

function QBuyCountDragonWar:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountDragonWar:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountDragonWar:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountDragonWar:getRefreshDesc()
	return "每日可购买次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountDragonWar:alertVipBuy()
	app:vipAlert({title = "挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.DRAGONWAR_BUY_COUNT}, false)
end

function QBuyCountDragonWar:requestBuy(succes, fail)
    remote.unionDragonWar:dragonWarBuyFightCountRequest(function ()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountDragonWar