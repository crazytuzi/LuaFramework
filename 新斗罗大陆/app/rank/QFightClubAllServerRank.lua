--搏击俱乐部全区排行

local QBaseRank = import(".QBaseRank")
local QFightClubAllServerRank = class("QFightClubAllServerRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetMyRankStyleDurian = import("..ui.widgets.rank.QUIWidgetMyRankStyleDurian")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QUIViewController = import("..ui.QUIViewController")

function QFightClubAllServerRank:ctor(options)
	QFightClubAllServerRank.super.ctor(self, options)
	self._list = {}
end

function QFightClubAllServerRank:needsUpdate( ... )
	return true
end

function QFightClubAllServerRank:update(success, fail)
	app:getClient():top50RankRequest("FIGHT_CLUB_REALTIME_TOP_50", remote.user.userId, function (data)
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

function QFightClubAllServerRank:getRefreshHour()
	local refreshTime =  24
	return refreshTime
end

function QFightClubAllServerRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QFightClubAllServerRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QFightClubAllServerRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		remote.fightClub:requestQueryFightClubDefendTeam(info.userId, function(data)
			local rivalInfo = (data.towerFightersDetail or {})[1] 
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    		options = {showAssist = true, fighter = rivalInfo, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true}}, {isPopCurrentDialog = false})
		end)
	end
end

function QFightClubAllServerRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "房间排名：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.fightClubRoomRank)
		style:setTFByIndex(6, info.game_area_name)
		style:setTFByIndex(7, "")
		style:setTFByIndex(8, "")
		local force, unit = q.convertLargerNumber(info.force)
		style:setTFByIndex(9, " 战斗力："..force..unit)
		style:setFloor(info.fightClubFloor, 0.6)
		style:autoLayout()
	end
end

function QFightClubAllServerRank:getSelfItem()
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
	style:setTFByIndex(3, "房间排名：")
	style:setTFByIndex(4, (myInfo.fightClubRoomRank or "0"))
	style:setAvatar(myInfo.avatar)
	style:setFloor(myInfo.fightClubFloor, 0.6)
	style:setVIP(myInfo.vip or 0)
	style:autoLayout()
	return item
end

return QFightClubAllServerRank
