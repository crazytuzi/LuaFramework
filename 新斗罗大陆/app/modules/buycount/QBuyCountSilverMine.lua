local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountSilverMine = class("QBuyCountSilverMine", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountSilverMine:ctor(options)
	-- body
	self._typeName = "silvermine_limit"
	self._vipField = "silvermine_limit"
	self._unlockType = "UNLOCK_SILVERMINE"
end

function QBuyCountSilverMine:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.silverMine:getBuyFightCount()
	self._num = self._totalNum
end

function QBuyCountSilverMine:getDesc()
	return "用少量钻石购买狩猎次数"
end

function QBuyCountSilverMine:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountSilverMine:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountSilverMine:getReciveNum()
	return "次数 X 1"
end

function QBuyCountSilverMine:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountSilverMine:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountSilverMine:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountSilverMine:getRefreshDesc()
	return "每日可购买狩猎次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountSilverMine:alertVipBuy()
	app:vipAlert({title = "魂兽森林可购买狩猎次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SILVERMINE_BUY_FIGHTCOUNT}, false)
end

function QBuyCountSilverMine:requestBuy(succes, fail)
    remote.silverMine:silvermineBuyFightCountRequest(function ()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountSilverMine