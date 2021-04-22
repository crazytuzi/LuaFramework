--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QStormArenaCurServerRank = class("QStormArenaCurServerRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QUIViewController = import("..ui.QUIViewController")

function QStormArenaCurServerRank:ctor(options)
	QStormArenaCurServerRank.super.ctor(self, options)
end

function QStormArenaCurServerRank:needsUpdate( ... )
	-- return true
	-- if q.isEmpty(self._list) then
	-- 	return true
	-- end

	-- -- roughly :)
	-- if tonumber(q.date("%H")) >= self:getRefreshHour() and self._lastRefreshHour < self:getRefreshHour() then
	-- 	return true
	-- end
	return true
end

function QStormArenaCurServerRank:update(success, fail)
	app:getClient():top50RankRequest("STORM_ENV_REALTIME_TOP_50", remote.user.userId, function (data)
	if data.rankings == nil or data.rankings.top50 == nil then 
		self.super:update(fail)
		return 
	end

	self._list = nil
	self._list = clone(data.rankings.top50)
	table.sort(self._list, function (x, y)
		return x.rank < y.rank
	end)
	self._myInfo = data.rankings.myself

	self.super:update(success)
end, fail)
end


-- function QStormArenaCurServerRank:getRefreshHour()
-- 	-- local config = QStaticDatabase:sharedDatabase():getConfiguration()
-- 	local refreshTime =  21
-- 	return refreshTime
-- end

function QStormArenaCurServerRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QStormArenaCurServerRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)

		style:setTFByIndex(3, "当前排名：")
		style:setTFByIndex(4, info.rank)
		style:setSpByIndex(1, false)

		style:autoLayout()
	end
end

function QStormArenaCurServerRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QStormArenaCurServerRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		remote.stormArena:stormArenaQueryDefenseHerosRequest(info.userId, function(data)
			local fighterInfo = (data.towerFightersDetail or {})[1] or {}

			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
	    		options = {fighterInfo = fighterInfo, isPVP = true}}, {isPopCurrentDialog = false})
		end)
	end
end

function QStormArenaCurServerRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleApple.new()
	style:setSoulTrial(myInfo.soulTrial)
	item:setStyle(style)

	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "当前排名：")
	style:setTFByIndex(4, (myInfo.rank or "0"))
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end


return QStormArenaCurServerRank
