local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountGloryTower = class("QBuyCountGloryTower", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogBuyCount = import("...ui.dialogs.QUIDialogBuyCount")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QBuyCountGloryTower:ctor(options)
	-- body
	self._typeName = "tower_of_glory_times"
	self._vipField = "tower_buy_fight_times_limit"
	self._unlockType = "UNLOCK_TOWER_OF_GLORY"
end

function QBuyCountGloryTower:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.tower:getTowerInfo().fightTimesBuyCount or 0
	self._num = self._totalNum
end

function QBuyCountGloryTower:getDesc()
	return "用少量钻石购买挑战次数"
end

function QBuyCountGloryTower:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountGloryTower:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountGloryTower:getReciveNum()
	return "次数 X 1"
end

function QBuyCountGloryTower:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountGloryTower:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountGloryTower:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountGloryTower:getRefreshDesc()
	return "每日可购买挑战次数在凌晨0点刷新" 
end

function QBuyCountGloryTower:alertVipBuy()
	app:vipAlert({title = "段位赛可购买挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.TOWER_BUY_COUNT}, false)
end

function QBuyCountGloryTower:requestBuy(succes, fail)
   	remote.tower:towerBuyFightCountRequest(function ()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogBuyCount.RFRESHE_GLORY_TOWER_FIGHT_NUM})
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountGloryTower