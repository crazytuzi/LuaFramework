--
-- Author: Your Name
-- Date: 2016-06-24 10:12:05
--
local QBaseRank = import(".QBaseRank")
local QTowerAreaRank2 = class("QTowerAreaRank2", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")

function QTowerAreaRank2:ctor(options)
	QTowerAreaRank2.super.ctor(self, options)
end

function QTowerAreaRank2:needsUpdate( ... )
	if q.isEmpty(self._list) then
		return true
	end

	-- roughly :)
	if tonumber(q.date("%H")) >= self:getRefreshHour() and self._lastRefreshHour < self:getRefreshHour() then
		return true
	end
end

function QTowerAreaRank2:update(success, fail)
	app:getClient():top50RankRequest("GLORY_COMPETITION_ENV_HISTORY_TOP_50", remote.user.userId, function (data)
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

function QTowerAreaRank2:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QTowerAreaRank2:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)

		style:setTFByIndex(3, "服务器名：")
		style:setTFByIndex(4, info.game_area_name)
		style:setSpByIndex(1, false)

		style:autoLayout()
	end
end

function QTowerAreaRank2:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QTowerAreaRank2:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		app:getClient():topGloryArenaRankUserRequest(info.userId, function(data)
			local fighter = (data.towerFightersDetail or {})[1] or {}
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    		options = {fighter = fighter, specialTitle1 = "服务器名：", specialValue1 = fighter.game_area_name, 
	    		specialTitle2 = "胜利场数：", specialValue2 = fighter.victory, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end)
	end
end

return QTowerAreaRank2
