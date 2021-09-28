
require ("app.cfg.shop_time_info")
require ("app.cfg.shop_time_reward_info")
require ("app.cfg.shop_time_recharge_info")

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local TimePrivilegeData = class("TimePrivilegeData")

function TimePrivilegeData:ctor()
	-- 全民奖励，已经领取过的列表
	self._tClaimedAwardList = {}
	-- 一些全局的信息
	self._tInitInfo = {
		_nSchedule = 0,
		_nFinishTime = 0,
		_nRechargeId = 0,
		_nExtraGold = 0,
	}
	-- 充值人数 
	self._nRechargeCount = 0

	-- 日期
	self._szDate = nil

	self._nStartTime = 0

	-- 进入功能后会置为true, 只有在大退后，这个状态才会重置为false
	self._bEnterFunctionMark = false
end


function TimePrivilegeData:storeInitInfo(data)
	self._szDate = G_ServerTime:getDate()

	local tInfo = {}
	tInfo._nSchedule = 0
	tInfo._nFinishTime = 0
	tInfo._nRechargeId = 0
	tInfo._nExtraGold = 0
	
	tInfo._nSchedule = data.progress
	if rawget(data, "time") then
		tInfo._nFinishTime = data.time
	end
	if rawget(data, "rechargeId") then
		tInfo._nRechargeId = data.rechargeId 
	end
	if rawget(data, "extra_gold") then
		tInfo._nExtraGold = data.extra_gold
	end

	self._tInitInfo = tInfo
end

function TimePrivilegeData:getInitInfo()
	return self._tInitInfo
end

function TimePrivilegeData:storeClaimAwardList(data)
	local tList = {}
	if rawget(data, "welfare_id") then
		for i, val in ipairs(data.welfare_id) do
			local id = val
			table.insert(tList, id)
		end
	end
	self._tClaimedAwardList = tList

	self._nRechargeCount = data.recharge_count
end

function TimePrivilegeData:getClaimAwardList()
	return self._tClaimedAwardList or {}
end

-- 获取充值人数
function TimePrivilegeData:getRechargeCount()
	return self._nRechargeCount or 0
end

-- 获取进度
function TimePrivilegeData:getSchedule()
	return self._tInitInfo._nSchedule or 0
end

-- 获取优惠结束时间
function TimePrivilegeData:getFinishTime()
	return self._tInitInfo._nFinishTime or 0
end

-- 获得优惠充值id
function TimePrivilegeData:getRechargeId()
	return self._tInitInfo._nRechargeId or 0
end

-- 获得额外赠送的元宝数
function TimePrivilegeData:getExtraGold()
	return self._tInitInfo._nExtraGold or 0
end

function TimePrivilegeData:isTimePrivilege(nId)
	return false
end

function TimePrivilegeData:storeStartTime(nTime)
	self._nStartTime = nTime or 0
end

function TimePrivilegeData:getOpenServerTime()
	return self._nStartTime
end

function TimePrivilegeData:isOpenFunction()
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TIME_PRIVILEGE) then
        return false
    end

    if self._nStartTime == 0 then
    	return false
    end

	-- 开服时间
	local nOpenTime = G_ServerTime:getTime() - self._nStartTime
	local nTime = 10 * 24 * 60 * 60
	if nOpenTime >= nTime then
		return true
	end

	return false
end

-- 有优惠充值订单
function TimePrivilegeData:hasPrivilegeRecharge()
	return self:getRechargeId() ~= 0
end

-- 获得recharge_info表的id
function TimePrivilegeData:getRealRechargeId()
	local nShopTimeRechargeId = G_Me.timePrivilegeData:getRechargeId()
	if nShopTimeRechargeId == 0 then
		return 0
	else
		local tShopTimeRecahrgeTmpl = shop_time_recharge_info.get(nShopTimeRechargeId)
		if tShopTimeRecahrgeTmpl then
			local appId =  G_PlatformProxy:getAppId()
			for i=1, recharge_info.getLength() do
				local tTmpl = recharge_info.indexOf(i)
				if tTmpl.app_id == appId then
					if tShopTimeRecahrgeTmpl.recharge_size == tTmpl.size then
						return tTmpl.id, nShopTimeRechargeId
					end
			 	end
			end
		end
	end

	return 0
end

function TimePrivilegeData:hasUnclaimedAward()
	local nRechargeCount = self:getRechargeCount()

    local tAwardList = {}
    local tClaimedList = G_Me.timePrivilegeData:getClaimAwardList()
    for i=1, shop_time_reward_info.getLength() do
        local tTmpl = shop_time_reward_info.indexOf(i)
   		if nRechargeCount >= tTmpl.num then
        	table.insert(tAwardList, tTmpl)
    	end
    end
    return table.nums(tAwardList) > table.nums(tClaimedList)
end


function TimePrivilegeData:_getLeftDay()
    local timeObj = G_ServerTime:getDateObject()
    local wday = timeObj.wday 

    return (8-wday) % 7
end

function TimePrivilegeData:needRefresh()
    local timeLeft = G_ServerTime:getCurrentDayLeftSceonds()
    local timeObj = G_ServerTime:getDateObject()
    local wday = timeObj.wday 
    -- 周一中午12点
    return wday == 2 and timeLeft == 12*60*60
end

-- 是否到一天的中午12点了，到了就表示货物已经刷新过了，做一个标记，进入限时优惠后把标记清除
function TimePrivilegeData:setGoodsRefreshedMark(bMark)
	self._bGoodsRefredhedMark = bMark or false
end

function TimePrivilegeData:getGoodsRefreshedMark()
	return self._bGoodsRefredhedMark or false
end

-- 进入功能后会置为true, 只有在大退后，这个状态才会重置为false
function TimePrivilegeData:setEnterFunctionMark(bMark)
	self._bEnterFunctionMark = bMark or true
end

function TimePrivilegeData:getEnterFunctionMark()
	return self._bEnterFunctionMark
end

function TimePrivilegeData:getRecordDate()
	return self._szDate
end

function TimePrivilegeData:updateRecordDate()
	self._szDate = G_ServerTime:getDate()
end

return TimePrivilegeData