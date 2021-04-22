--
-- @Author: Kumo
-- 大富翁购买次数
--
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountMonopoly = class("QBuyCountMonopoly", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountMonopoly:ctor(options)
	-- body
	self._typeName = "monopoly_buy_times"
	self._vipField = ""
	self._unlockType = "UNLOCK_BINGHUOLIANGYIYAN"
end

function QBuyCountMonopoly:refreshInfo()
	-- self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalVIPNum = 0
	self._totalNum = QStaticDatabase.sharedDatabase():getConfigurationValue("buy_dice_count_limit")
	self._buyCount = remote.monopoly.monopolyInfo.buyDiceCount or 0
	self._num = self._totalNum
end

function QBuyCountMonopoly:getDesc()
	return "用少量钻石购买一次骰子次数"
end

function QBuyCountMonopoly:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountMonopoly:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountMonopoly:getReciveNum()
	return "次数 X 1"
end

function QBuyCountMonopoly:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountMonopoly:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountMonopoly:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountMonopoly:getRefreshDesc()
	return "解完全部毒，可以获得终极大奖哦～" 
end

function QBuyCountMonopoly:alertVipBuy()
	app:vipAlert({title = "冰火两仪眼购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.WORLDBOSS_BUY_COUNT}, false)
end

function QBuyCountMonopoly:requestBuy(succes, fail)
   	remote.monopoly:monopolyBuyDiceRequest(1,function ()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountMonopoly