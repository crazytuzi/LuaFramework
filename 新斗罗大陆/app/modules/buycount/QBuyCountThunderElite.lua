-- @Author: xurui
-- @Date:   2017-01-19 17:58:59
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-07-05 17:25:11
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountThunderElite = class("QBuyCountThunderElite", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountThunderElite:ctor(options)
	-- body
	self._typeName = "thunder_elite"
	self._unlockType = "UNLOCK_THUNDER"
end

function QBuyCountThunderElite:refreshInfo()
	self._totalNum = QStaticDatabase:sharedDatabase():getConfiguration()["THUNDER_ELITE_BUY"].value
	self._buyCount = remote.thunder:getThunderFighter().thunderEliteChallengeBuyCount or 0
	self._num = self._totalNum
end

function QBuyCountThunderElite:getDesc()
	return "用少量钻石购买挑战次数"
end

function QBuyCountThunderElite:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountThunderElite:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountThunderElite:getReciveNum()
	return "次数 X 1"
end

function QBuyCountThunderElite:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountThunderElite:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountThunderElite:checkVipCanGrade()
	return false
end

function QBuyCountThunderElite:getRefreshDesc()
	return "每日可购买掠夺次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountThunderElite:alertVipBuy()

end

function QBuyCountThunderElite:requestBuy(succes, fail)
   	remote.thunder:thunderBuyEliteRequest(function ()
   		remote.thunder:updateEliteBuyCount()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountThunderElite