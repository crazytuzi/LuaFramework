--[[
******随机商店*******

	-- by david.dai
	-- 2014/06/12
]]

local RandomStore = class("RandomStore")

function RandomStore:ctor(type)
	-- self.super.ctor(self)
	self:init(type)
end

function RandomStore:init(type)
	--商店类型
	self.type = type
	--商品列表
	self.commodityList = {}
	self.enabled = false
	self.openState = false
	self.configure = RandomMallConfigure:objectByID(type)
end

function RandomStore:dispose()
	self.super.dispose(self)
	self.type 			= nil
	self.commodityList 	= nil
	TFDirector:unRequire('lua.gamedata.base.GameObject')
end

--获取商店类型
function RandomStore:getType()
	return self.type
end

--商店是否处于激活状态
function RandomStore:isEnabled()
	return self.enabled
end

--设置商品列表
function RandomStore:setCommodityList(commodityList)
	self.commodityList = commodityList
end

--获取商品列表
function RandomStore:getCommodityList()
	return self.commodityList
end

function RandomStore:getCommodity(id)
	if self.commodityList == nil then 
		return nil
	end

	for _,tmp in pairs(self.commodityList) do
		if tmp:getId() == id then
			return tmp
		end
	end
	return nil
end

--设置自动刷新剩余时间，单位/毫秒
function RandomStore:setAutoRefreshRemaining(milliseconds)
	self.autoRefreshRemaining = math.ceil(milliseconds/1000)
	self.autoRefreshTime = MainPlayer:getNowtime() + self.autoRefreshRemaining
end

--设置自动刷新剩余时间，单位/秒
function RandomStore:getAutoRefreshRemaining()
	return self.autoRefreshRemaining
end

--获取自动刷新时间(秒)
function RandomStore:getAutoRefreshTime()
	return self.autoRefreshTime
end

--获取自动刷新时间的时钟表达式字符串
function RandomStore:getAutoRefreshTimeAsHHMMSS()
	local hhmmss = os.date("%X", self.autoRefreshTime)
	return hhmmss
end

--获取自动刷新时间的时钟表达式字符串或者倒计时
function RandomStore:getAutoRefreshTimeAsString()
	local seconds = self.autoRefreshTime
	local current = MainPlayer:getNowtime()
	local remaining = seconds - current
	self.autoRefreshRemaining = remaining
	if remaining > 3600 then
		return os.date("%H:%M(%p)", seconds)
	elseif remaining > 60 then
		--return math.ceil(remaining/60) .. "分钟后"
		return stringUtils.format(localizable.RandomStore_Min_Later, math.ceil(remaining/60))
	else
		if remaining < 0 then
			--return "正在刷新"
			return localizable.RandomStore_Refresh
		end
		--return remaining .. "秒后"
		return stringUtils.format(localizable.RandomStore_Sec_Later, remaining)
	end
end

--设置手动刷新消耗
function RandomStore:setRefreshCost(refreshCost)
	self.refreshCost = refreshCost
end

--获取手动刷新消耗
function RandomStore:getRefreshCost()
	return self.refreshCost
end

function RandomStore:setManualRefreshCount(manualRefreshCount)
	self.manualRefreshCount = manualRefreshCount
end

function RandomStore:getManualRefreshCount()
	return self.manualRefreshCount
end

--设置开放时间
function RandomStore:setOpentime(opentime)
	self.opentime = opentime
end
--设置开放时间
function RandomStore:getOpentime()
	return self.opentime
end

--设置开放时间
function RandomStore:setOpenState(openState)
	self.openState = openState
end
--设置开放时间
function RandomStore:getOpenState()
	return self.openState
end

function RandomStore:isOpen()
	local gang_shop_level = FactionManager:getShopLevel() or 0
	if gang_shop_level < self.configure.gang_level then
		return false
	end
	if MainPlayer:getVipLevel() >= self.configure.openVip then
		return true
	end
	if self.openState and self.opentime + self.configure.showTime > MainPlayer:getNowtime()*1000 then
		return true
	end
	self.openState = false
	return self.openState
end

return RandomStore