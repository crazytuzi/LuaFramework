-- @Author: xurui
-- @Date:   2018-08-14 20:57:03
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-08-24 18:20:41
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountMetalCity = class("QBuyCountMetalCity", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountMetalCity:ctor(options)
	-- body
	self._vipField = "metalcity_tims2"
	self._typeName = "metalcity_num2"
	self._unlockType = "UNLOCK_METALCITY"
end

function QBuyCountMetalCity:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.metalCity:getMetalCityMyInfo().buyCount or 0

	self._num = self._totalNum
end

function QBuyCountMetalCity:getDesc()
	return "现有钻石："..remote.user.token
end

function QBuyCountMetalCity:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountMetalCity:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountMetalCity:getReciveNum()
	return "次数 X 1"
end

function QBuyCountMetalCity:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountMetalCity:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountMetalCity:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountMetalCity:getRefreshDesc()
	return "每日可购买金属之城战斗次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountMetalCity:alertVipBuy()
	app:vipAlert({title = "金属之城战斗次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, vipField = self._vipField}, false)
end

function QBuyCountMetalCity:requestBuy(succes, fail)
   	remote.metalCity:requestMetalCityBuyFightCount(function ()
   		remote.metalCity:updateMetalCityBuyFightCount()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountMetalCity