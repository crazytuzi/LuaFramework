--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QArenaRank = class("QArenaRank", QBaseRank)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleBanana = import("..ui.widgets.rank.QUIWidgetRankStyleBanana")

function QArenaRank:ctor(options)
	QArenaRank.super.ctor(self, options)
end

function QArenaRank:needsUpdate( ... )
	if q.isEmpty(self._list) then
		return true
	end

	-- roughly :)
	if tonumber(q.date("%H")) >= self:getRefreshHour() and self._lastRefreshHour < self:getRefreshHour() then
		return true
	end
end

function QArenaRank:update(success, fail)
	app:getClient():top50RankRequest("ARENA_TOP_50", remote.user.userId, function (data)
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

function QArenaRank:getRefreshHour()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	local refreshTime = config["SYSTEM_RESET_TIME_SPECIAL"].value or 21
	return refreshTime
end

function QArenaRank:getEmptySprite()
	local node = CCNode:create()
	local paths = QResPath("rank_empty_tips")
	local sp1 = CCSprite:create(paths[1])
	sp1:setPosition(ccp(-195, -36))
	node:addChild(sp1)
	local sp2 = CCSprite:create(paths[2])
	sp2:setPosition(ccp(29, -36))
	node:addChild(sp2)
	local sp3 = CCSprite:create(paths[3])
	sp3:setPosition(ccp(0, -86))
	node:addChild(sp3)
	return node
end

function QArenaRank:setTips(node)
	node:setString("虚位以待，敬请期待！")
end

function QArenaRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleBanana.new()
	item:setStyle(style)
	return item
end

function QArenaRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:autoLayout()
	end
end

function QArenaRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QArenaRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		local options = {}
		options.specialTitle1 = "胜利场数："
		options.forceTitle = "防守战力："
		options.isPVP = true
		self:queryFighterWithArena(info.userId, options)
	end
end

function QArenaRank:getSelfItem()
	return nil
end

return QArenaRank
