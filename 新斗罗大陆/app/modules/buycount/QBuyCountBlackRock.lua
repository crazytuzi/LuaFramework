local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountBlackRock = class("QBuyCountBlackRock", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountBlackRock:ctor(options)
	-- body
	self._typeName = "blackrock_award"
	self._vipField = "blackrock_award"
	self._unlockType = "UNLOCK_BLACKROCK"
end

function QBuyCountBlackRock:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.blackrock:getMyInfo().buyAwardCount or 0
	self._num = self._totalNum
end

function QBuyCountBlackRock:getDesc()
	return "用少量钻石购买奖励次数"
end

function QBuyCountBlackRock:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountBlackRock:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountBlackRock:getReciveNum()
	return "次数 X 1"
end

function QBuyCountBlackRock:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountBlackRock:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountBlackRock:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountBlackRock:getRefreshDesc()
	return "每日可购买奖励次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountBlackRock:alertVipBuy()
	app:vipAlert({title = "奖励次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.BLACKROCK_BUY_AWARDS_COUNT}, false)
end

function QBuyCountBlackRock:requestBuy(succes, fail)
   	remote.blackrock:blackRockBuyAwardCountRequest(function ()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountBlackRock