local QBaseRank = import(".QBaseRank")
local QPersonalTeamArenaRank = class("QPersonalTeamArenaRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QPersonalTeamArenaRank:ctor(options)
	QPersonalTeamArenaRank.super.ctor(self, options)
end

function QPersonalTeamArenaRank:needsUpdate( ... )
	return true
end

function QPersonalTeamArenaRank:update(success, fail)
	app:getClient():top50RankRequest("TEAM_SCORE_DAILY_SCORE_TOP_50", remote.user.userId, function (data)
	if data.rankings == nil or data.rankings.top50 == nil then 
		self.super:update(fail)
		return 
	end

	self._list = nil
	self._list = clone(data.rankings.top50)
	-- for k, v in ipairs(self._list) do
	-- 	v.avatar = v.icon
	-- end
	table.sort(self._list, function (x, y)
		return x.rank < y.rank
	end)
	if data.rankings.myself.rank == 0 then
		data.rankings.myself.rank = nil
	end
	self._myInfo = data.rankings.myself
	
	self.super:update(success)
end, fail)
end

function QPersonalTeamArenaRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QPersonalTeamArenaRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setTFByIndex(3, "个人积分：")
		style:setTFByIndex(4, (info.teamArenaScore or "0"))
		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:autoLayout()
	end
end

function QPersonalTeamArenaRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)

	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "个人积分：")
	style:setTFByIndex(4, (myInfo.teamArenaScore or "0"))
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QPersonalTeamArenaRank