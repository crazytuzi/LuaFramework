-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 19:14:48
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-14 16:30:49
--

local QBaseRank = import(".QBaseRank")
local QSotoTeamRank = class("QSotoTeamRank", QBaseRank)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QUIWidgetMyRankStyleDurian = import("..ui.widgets.rank.QUIWidgetMyRankStyleDurian")
local QUIViewController = import("..ui.QUIViewController")

function QSotoTeamRank:ctor(options)
	QSotoTeamRank.super.ctor(self, options)
end

function QSotoTeamRank:update(success, fail)
	app:getClient():top50RankRequest("SOTO_TEAM_TOP_50", remote.user.userId, function (data)
		if data.rankings == nil or data.rankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = data.rankings.top50 or {}
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		self._myInfo = data.rankings.myself

		self.super:update(success)
	end, fail)
end

function QSotoTeamRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QSotoTeamRank:renderItem(item, index)
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
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.rank or 0)
		style:setTFByIndex(6, info.game_area_name or "")
		style:setSpByIndex(1, false)

		style:autoLayout()
	end
end

function QSotoTeamRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QSotoTeamRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		local isEquilibrium = remote.sotoTeam:checkIsEquilibriumSeason()
		remote.sotoTeam:sotoTeamQueryFighterRequest(info.userId, function(data)
			local rivalInfo = (data.towerFightersDetail or {})[1] 
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    		options = {fighter = rivalInfo, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true, isEquilibrium = isEquilibrium}}, {isPopCurrentDialog = false})
		end)
	end
end

function QSotoTeamRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleDurian.new()
	style:setSoulTrial(myInfo.soulTrial)
	item:setStyle(style)

	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)
	style:setVIP(myInfo.vip or 0)

	style:setTFByIndex(3, "当前排名：")
	style:setTFByIndex(4, myInfo.rank or "0")
	style:autoLayout()
	return item
end

return QSotoTeamRank