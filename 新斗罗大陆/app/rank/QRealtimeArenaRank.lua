--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QRealtimeArenaRank = class("QRealtimeArenaRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetRankStyleBanana = import("..ui.widgets.rank.QUIWidgetRankStyleBanana")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetMyRankStyleBanana = import("..ui.widgets.rank.QUIWidgetMyRankStyleBanana")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QRealtimeArenaRank:ctor(options)
	QRealtimeArenaRank.super.ctor(self, options)
end

function QRealtimeArenaRank:needsUpdate( ... )
	return true
end

function QRealtimeArenaRank:update(success, fail)
	app:getClient():top50RankRequest("ARENA_REALTIME_TOP_50", remote.user.userId, function (data)
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

function QRealtimeArenaRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleBanana.new()
	item:setStyle(style)
	return item
end

function QRealtimeArenaRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		local famousPersonValue = db:getFamousPersonValueByRank("mrt_dhc", index) or 0
		style:setTFByIndex(3, "名人堂积分："..famousPersonValue)

		style:autoLayout()
	end
end

function QRealtimeArenaRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QRealtimeArenaRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		local options = {}
		options.specialTitle1 = "胜利场数："
		options.forceTitle = "防守战力："
		options.isPVP = true
		self:queryFighterWithArena(info.userId, options)
	end
end

function QRealtimeArenaRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleBanana.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)
	local famousPersonValue = db:getFamousPersonValueByRank("mrt_dhc", myInfo.rank) or 0
	style:setTFByIndex(3, "  名人堂积分："..famousPersonValue)

	style:autoLayout()
	return item
end


return QRealtimeArenaRank
