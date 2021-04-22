local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountStormArena = class("QBuyCountStormArena", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountStormArena:ctor(options)
	-- body
	self._typeName = "storm_arena_times"
	self._vipField = "storm_arena_times"
	self._unlockType = "UNLOCK_STORM_ARENA"
end

function QBuyCountStormArena:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)

	local stormArenaInfo = remote.stormArena:getStormArenaInfo()
	self._buyCount = stormArenaInfo.fightBuyCount or 0
	self._num = self._totalNum
end

function QBuyCountStormArena:getDesc()
	return "用少量钻石购买挑战次数"
end

function QBuyCountStormArena:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountStormArena:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountStormArena:getReciveNum()
	return "次数 X 1"
end

function QBuyCountStormArena:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountStormArena:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountStormArena:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountStormArena:getRefreshDesc()
	return "每日可购买次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountStormArena:alertVipBuy()
	app:vipAlert({title = "挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.STORM_ARENA_RESET_COUNT}, false)
end

function QBuyCountStormArena:requestBuy(succes, fail)
    remote.stormArena:requestStormArenaBuyFightTimes(function ()
        remote.stormArena:updateStormArenaBuyCount()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountStormArena