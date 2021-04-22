-- @Author: xurui
-- @Date:   2017-01-19 14:58:39
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-05-30 17:00:40
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountUnionInstance = class("QBuyCountUnionInstance", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountUnionInstance:ctor(options)
	self._typeName = "sociaty_chapter_times"
	self._vipField = "sociaty_chapter_times"
	self._unlockType = "GONGHUIFUBEN_UNLOCK_SKIP"
end

function QBuyCountUnionInstance:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	
	local userConsortia = remote.user:getPropForKey("userConsortia")

	if userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_buy_at then
		self._buyCount = 0
	else
		self._buyCount = userConsortia.consortia_boss_buy_count or 0
	end
	self._num = self._totalNum
end

function QBuyCountUnionInstance:getDesc()
	return "购买后可增加一次攻击次数"
end

function QBuyCountUnionInstance:getCountDesc()
	return "（今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum.."）"
end

function QBuyCountUnionInstance:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountUnionInstance:getReciveNum()
	return "次数 X 1"
end

function QBuyCountUnionInstance:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountUnionInstance:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountUnionInstance:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountUnionInstance:getRefreshDesc()
	return "每日可购买宗门副本次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

function QBuyCountUnionInstance:alertVipBuy()
	app:vipAlert({title = "宗门副本可购买攻击次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SOCIETYDUNGEON_BUY_FIGHTCOUNT}, false)
end

function QBuyCountUnionInstance:requestBuy(succes, fail)
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	if curTimeTbl.hour < startTime or curTimeTbl.hour >= endTime then
		app.tip:floatTip("当前时段无法购买")
		return
	else
		remote.union:unionBuyFightCountRequest(1, false, function (data)
			remote.union:sendBuyFightCountSuccess()
	    	if succes then
	    		succes()
	    	end
	    end,function ()
	    	if fail then
	    		fail()
	    	end
		end)
	end
end

return QBuyCountUnionInstance