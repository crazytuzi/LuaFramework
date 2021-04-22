-- @Author: xurui
-- @Date:   2017-01-19 18:35:01
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-27 15:52:36
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountMaritimeRobbery = class("QBuyCountMaritimeRobbery", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountMaritimeRobbery:ctor(options)
	-- body
	self._typeName = "maritime_plunder"
	self._vipField = "maritime_plunder"
	self._unlockType = "UNLOCK_MARITIME"
end

function QBuyCountMaritimeRobbery:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.maritime:getMyMaritimeInfo().buyLootCnt or 0
	self._num = self._totalNum
end

function QBuyCountMaritimeRobbery:getDesc()
	return "用少量钻石购买掠夺次数"
end

function QBuyCountMaritimeRobbery:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountMaritimeRobbery:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountMaritimeRobbery:getReciveNum()
	return "次数 X 1"
end

function QBuyCountMaritimeRobbery:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountMaritimeRobbery:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountMaritimeRobbery:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountMaritimeRobbery:getRefreshDesc()
	return "每日可购买掠夺次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountMaritimeRobbery:alertVipBuy()
	app:vipAlert({title = "仙品掠夺次数购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.MARITIME_BUY_LOOTCOUNT}, false)
end

function QBuyCountMaritimeRobbery:requestBuy(succes, fail)
   	remote.maritime:requestBuyRobberyNum(function ()
   		remote.maritime:updateRobberyNum()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountMaritimeRobbery