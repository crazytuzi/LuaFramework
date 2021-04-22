-- @Author: xurui
-- @Date:   2017-01-19 17:43:18
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-07-05 17:25:32
local QBuyCountBase = import(".QBuyCountBase")
local QBuyCountWorldBoss = class("QBuyCountWorldBoss", QBuyCountBase)
local QVIPUtil = import("...utils.QVIPUtil")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBuyCountWorldBoss:ctor(options)
	-- body
	self._typeName = "yaosai_boss_times"
	self._vipField = "yaosai_boss_times"
	self._unlockType = "UNLOCK_SHIJIEBOSS"
end

function QBuyCountWorldBoss:refreshInfo()
	self._totalVIPNum = QVIPUtil:getCountByWordField(self._vipField, QVIPUtil:getMaxLevel())
	self._totalNum = QVIPUtil:getCountByWordField(self._vipField)
	self._buyCount = remote.worldBoss:getWorldBossInfo().buyFightCount or 0
	self._num = self._totalNum
end

function QBuyCountWorldBoss:getDesc()
	return "用少量钻石购买一次攻击次数"
end

function QBuyCountWorldBoss:getCountDesc()
	return "(今日可购买次数"..(self._totalNum - self._buyCount).."/"..self._totalNum..")"
end

function QBuyCountWorldBoss:getConsumeNum()
	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount+1)
	return config.money_num or 0
end

function QBuyCountWorldBoss:getReciveNum()
	return "次数 X 1"
end

function QBuyCountWorldBoss:getIconPath()
    local unlockInfo = app.unlock:getConfigByKey(self._unlockType)
	return unlockInfo.icon
end

--是否可购买
function QBuyCountWorldBoss:checkCanBuy()
	return self._totalNum > self._buyCount
end

--是否可升级VIP提升次数
function QBuyCountWorldBoss:checkVipCanGrade()
	return self._totalVIPNum > self._totalNum
end

function QBuyCountWorldBoss:getRefreshDesc()
	return "攻打boss可能获得幸运奖励哦" 
end

function QBuyCountWorldBoss:alertVipBuy()
	app:vipAlert({title = "世界BOSS购买", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.WORLDBOSS_BUY_COUNT}, false)
end

function QBuyCountWorldBoss:requestBuy(succes, fail)
   	remote.worldBoss:requestBuyWorldBossFightCount(function ()
   		remote.worldBoss:updateBuyCount()
   		remote.user:addPropNumForKey("todayWorldBossBuyCount")--记录魔鲸购买攻击次数
    	if succes then
    		succes()
    	end
    end,function ()
    	if fail then
    		fail()
    	end
	end)
end

return QBuyCountWorldBoss