-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 19:23:54
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-09-12 18:13:48
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountSotoTeam = class("QBuyCountSotoTeam", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")

function QBuyCountSotoTeam:ctor(options)
	-- body
	self._typeName = "soto_team_times"
	self._vipField = "soto_team_times_limit"
	self._unlockType = "UNLOCK_SOTO_TEAM"
end

function QBuyCountSotoTeam:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.sotoTeam:getMyInfo().fightCountBuy or 0
	self._num = self._totalNum
end

function QBuyCountSotoTeam:getDesc()
	return "用少量钻石购买挑战次数"
end

function QBuyCountSotoTeam:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountSotoTeam:getConsumeNum()
	local config = db:getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountSotoTeam:getReciveNum()
	return "次数 X 1"
end

function QBuyCountSotoTeam:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountSotoTeam:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountSotoTeam:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountSotoTeam:getRefreshDesc()
	return "每日可购买次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountSotoTeam:alertVipBuy()
	app:vipAlert({title = "云顶之战可购买挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.ARENA_RESET_COUNT}, false)
end

function QBuyCountSotoTeam:requestBuy(succes, fail)
    remote.sotoTeam:sotoTeamBuyFightCountRequest(function ()
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountSotoTeam