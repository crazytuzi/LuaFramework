-- @Author: xurui
-- @Date:   2017-05-31 10:41:16
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-16 18:48:35
local QBaseRank = import(".QBaseRank")
local QSanctuaryRank = class("QSanctuaryRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QUIViewController = import("..ui.QUIViewController")

function QSanctuaryRank:ctor(options)
	QSanctuaryRank.super.ctor(self, options)
end

function QSanctuaryRank:needsUpdate( ... )
	return true
end

function QSanctuaryRank:update(success, fail)
	app:getClient():top50RankRequest("SANCTUARY_WAR_SCORE_TOP_50", remote.user.userId, function (data)
		if data.rankings == nil or data.rankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = clone(data.rankings.top50) or {}
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		self._myInfo = data.rankings.myself

		self.super:update(success)
	end, fail)
end

function QSanctuaryRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QSanctuaryRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)

		style:setTFByIndex(3, "淘汰胜场：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, string.format("%d（积分：%d）", info.sanctuaryWarAuditionTotalWinCount, info.sanctuaryWarScore))
		style:setTFByIndex(6, info.game_area_name)
		style:setTFByIndex(7, "")
		style:setSpByIndex(1, false)

		style:autoLayout()
	end
end

function QSanctuaryRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QSanctuaryRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		remote.sanctuary:sanctuaryWarQueryFighterRequest(info.userId, function(data)
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = info.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end)
	end
end

function QSanctuaryRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)
	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "淘汰胜场：")
	style:setTFByIndex(4, string.format("%d（积分：%d）", myInfo.sanctuaryWarAuditionTotalWinCount or 0, myInfo.sanctuaryWarScore))
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QSanctuaryRank