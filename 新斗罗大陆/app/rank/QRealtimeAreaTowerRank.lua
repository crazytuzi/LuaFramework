--
-- Author: xurui
-- Date: 2016-06-24 10:09:44
--
local QBaseRank = import(".QBaseRank")
local QRealtimeAreaTowerRank = class("QRealtimeAreaTowerRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleDurian = import("..ui.widgets.rank.QUIWidgetMyRankStyleDurian")
local QUIViewController = import("..ui.QUIViewController")

function QRealtimeAreaTowerRank:ctor(options)
	QRealtimeAreaTowerRank.super.ctor(self, options)
end

function QRealtimeAreaTowerRank:needsUpdate( ... )
	return true
end

function QRealtimeAreaTowerRank:update(success, fail)
	app:getClient():top50RankRequest("TOWER_FLOOR_ENV_REALTIME_TOP_50", remote.user.userId, function (data)
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

function QRealtimeAreaTowerRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QRealtimeAreaTowerRank:renderItem(item, index)
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
		style:setTFByIndex(4, "最高段位：")
		style:setTFByIndex(5, info.towerScore or 0)

		if info.towerFloor then
			style:setFloor(info.towerFloor, 0.6, "tower")
			style:setTFByIndex(6, db:getGloryTower(info.towerFloor).name or "")
		end

		local famousPersonValue = db:getFamousPersonValueByRank("mrt_dws", index) or 0
		style:setTFByIndex(9, "  名人堂积分: "..famousPersonValue)

		style:autoLayout()
	end
end

function QRealtimeAreaTowerRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QRealtimeAreaTowerRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		remote.tower:towerQueryFightRequest(info.userId, info.env, info.actorIds, function(data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    		options = {fighter = data.towerFightersDetail[1], forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
		end)
	end
end

function QRealtimeAreaTowerRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleDurian.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setVIP(myInfo.vip or 0)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)
	style:setFloor(myInfo.towerFloor, 0.55, "tower")

	style:setTFByIndex(3, "当前积分：")
	style:setTFByIndex(4, myInfo.towerScore or "0")

	local famousPersonValue = db:getFamousPersonValueByRank("mrt_dws", myInfo.rank) or 0
	style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

	style:autoLayout()
	return item
end

return QRealtimeAreaTowerRank
