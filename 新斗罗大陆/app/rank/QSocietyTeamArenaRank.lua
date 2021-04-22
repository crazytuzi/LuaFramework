local QBaseRank = import(".QBaseRank")
local QSocietyTeamArenaRank = class("QSocietyTeamArenaRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QSocietyTeamArenaRank:ctor(options)
	QSocietyTeamArenaRank.super.ctor(self, options)
end

function QSocietyTeamArenaRank:needsUpdate( ... )
	return true
end

function QSocietyTeamArenaRank:update(success, fail)
	app:getClient():top50RankRequest("TEAM_SCORE_CONSORTIA_SCORE_TOP_50", remote.user.userId, function (data)
	if data.consortiaRankings == nil or data.consortiaRankings.top50 == nil then 
		self.super:update(fail)
		return 
	end

	self._list = nil
	self._list = clone(data.consortiaRankings.top50)
	for k, v in ipairs(self._list) do
		v.avatar = v.icon
	end
	table.sort(self._list, function (x, y)
		return x.rank < y.rank
	end)
	self._myInfo = data.consortiaRankings.myself
	self._myInfo.avatar = self._myInfo.icon
	
	self.super:update(success)
end, fail)
end

function QSocietyTeamArenaRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QSocietyTeamArenaRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setTFByIndex(3, "军团积分：")
		style:setTFByIndex(4, (info.team_arena_score or ""))
		style:setUnionAvatar(info.icon, info.consortiaWarFloor)
		style:setSpByIndex(1, false)
		style:setVIP(info.vip)
		-- style:setVIP(info.vip or 0)
		-- style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:autoLayout()
	end
end


return QSocietyTeamArenaRank