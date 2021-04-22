local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountArena = class("QBuyCountArena", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountArena:ctor(options)
	-- body
	self._typeName = "arena_times"
	self._vipField = "arena_times_limit"
	self._unlockType = "UNLOCK_ARENA"
end

function QBuyCountArena:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.arena:madeReciveData("self").arenaResponse.mySelf.fightBuyCount
	self._num = self._totalNum
end

function QBuyCountArena:getDesc()
	return "用少量钻石购买挑战次数"
end

function QBuyCountArena:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountArena:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountArena:getReciveNum()
	return "次数 X 1"
end

function QBuyCountArena:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountArena:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountArena:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountArena:getRefreshDesc()
	return "每日可购买次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountArena:alertVipBuy()
	app:vipAlert({title = "斗魂场可购买挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.ARENA_RESET_COUNT}, false)
end

function QBuyCountArena:requestBuy(succes, fail)
    remote.arena:requestBuyFighterCount(function ()
		remote.activity:updateLocalDataByType(505,1)
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountArena