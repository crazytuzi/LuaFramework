-- @Author: xurui
-- @Date:   2017-01-19 18:11:59
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-27 15:52:14
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountMaritimeTransport = class("QBuyCountMaritimeTransport", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountMaritimeTransport:ctor(options)
	-- body
	self._typeName = "maritime_num"
	self._vipField = "maritime_num"
	self._unlockType = "UNLOCK_MARITIME"
end

function QBuyCountMaritimeTransport:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.maritime:getMyMaritimeInfo().buyMaritimeCnt or 0
	self._num = self._totalNum
end

function QBuyCountMaritimeTransport:getDesc()
	return "用少量钻石购买运送次数"
end

function QBuyCountMaritimeTransport:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountMaritimeTransport:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountMaritimeTransport:getReciveNum()
	return "次数 X 1"
end

function QBuyCountMaritimeTransport:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountMaritimeTransport:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountMaritimeTransport:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountMaritimeTransport:getRefreshDesc()
	return "每日可购买运送次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountMaritimeTransport:alertVipBuy()
	app:vipAlert({title = "仙品运送次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.MARITIME_BUY_TRANSPORT_COUNT}, false)
end

function QBuyCountMaritimeTransport:requestBuy(succes, fail)
   	remote.maritime:requestBuyMaritimeShipNum(function ()
   		remote.maritime:updateTransportNum()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountMaritimeTransport