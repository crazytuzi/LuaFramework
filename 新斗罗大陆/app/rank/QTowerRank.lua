--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QTowerRank = class("QTowerRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")

function QTowerRank:ctor(options)
	QTowerRank.super.ctor(self, options)
end

function QTowerRank:needsUpdate( ... )
	if q.isEmpty(self._list) then
		return true
	end

	-- roughly :)
	if tonumber(q.date("%H")) >= self:getRefreshHour() and self._lastRefreshHour < self:getRefreshHour() then
		return true
	end
end

function QTowerRank:update(success, fail)
	app:getClient():top50RankRequest("TOWER_FLOOR_TOP_50", remote.user.userId, function (data)
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


function QTowerRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QTowerRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:setTFByIndex(3, "荣誉积分：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.towerScore or 0)
		style:setTFByIndex(6, info.game_area_name or "")

		if info.towerFloor then
			style:setFloor(info.towerFloor, 0.6, "tower")
		end
		style:autoLayout()
	end
end

function QTowerRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QTowerRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		remote.tower:towerQueryFightRequest(info.userId, info.env, info.actorIds, function(data)
			local fighter = data.towerFightersDetail[1]
			local towerScore = fighter.towerScore or 0
			if towerScore <= 0 then
				towerScore = info.towerScore or 0
			end
	  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    		options = {fighter = fighter, specialTitle1 = "荣誉积分：", specialValue1 = towerScore, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
	  	end)
	end
end

return QTowerRank
