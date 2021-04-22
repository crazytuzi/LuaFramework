local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountGloryArena = class("QBuyCountGloryArena", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountGloryArena:ctor(options)
	-- body
	self._typeName = "competion_times"
	self._vipField = "competion_times_limit"
	self._unlockType = "UNLOCK_ARENA"
end

function QBuyCountGloryArena:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.tower.gloryArenaMyInfo.fightBuyCount or 0
	self._num = self._totalNum
end

function QBuyCountGloryArena:getDesc()
	return "用少量钻石购买挑战次数"
end

function QBuyCountGloryArena:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountGloryArena:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountGloryArena:getReciveNum()
	return "次数 X 1"
end

function QBuyCountGloryArena:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountGloryArena:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountGloryArena:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountGloryArena:getRefreshDesc()
	return "每日可购买挑战次数在凌晨0点刷新" 
end

function QBuyCountGloryArena:alertVipBuy()
	app:vipAlert({title = "争霸赛可购买挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.GLORY_ARENA_RESET_COUNT}, false)
end

function QBuyCountGloryArena:requestBuy(succes, fail)
   	remote.tower:requestGloryArenaBuyFightTimes(function ()
        remote.tower:updateGloryArenaBuyCount()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountGloryArena