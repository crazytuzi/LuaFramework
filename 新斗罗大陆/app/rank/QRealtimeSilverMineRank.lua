--
-- Author: Your Name
-- Date: 2016-07-28 18:58:54
--QRealtimeSilverMineRank
local QBaseRank = import(".QBaseRank")
local QRealtimeSilverMineRank = class("QRealtimeSilverMineRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QRealtimeSilverMineRank:ctor(options)
	QRealtimeSilverMineRank.super.ctor(self, options)
end

function QRealtimeSilverMineRank:needsUpdate( ... )
	return true
end

function QRealtimeSilverMineRank:update(success, fail)
	app:getClient():top50RankRequest("SILVERMINE_MINING_LEVEL", remote.user.userId, function (data)
		if data.silverMineRankResponse == nil or data.silverMineRankResponse.ranks == nil then 
			self.super:update(fail)
			return 
		end

		self._list = nil
		self._list = clone(data.silverMineRankResponse.ranks)
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		self._myInfo = data.silverMineRankResponse.myrank

		self.super:update(success)
	end, fail)
end

function QRealtimeSilverMineRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QRealtimeSilverMineRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setTFByIndex(3, "狩猎等级：")
		style:setTFByIndex(4, (info.miningLevel or ""))
		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		local famousPersonValue = db:getFamousPersonValueByRank("mrt_hssl", index) or 0
		style:setTFByIndex(5, "   名人堂积分："..famousPersonValue)

		style:autoLayout()
	end
end

function QRealtimeSilverMineRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QRealtimeSilverMineRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		local options = {}
		options.isPVP = true
		self:queryFighterWithArena(info.userId, options)
	end
end

function QRealtimeSilverMineRank:getSelfItem()
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

	style:setTFByIndex(3, "狩猎等级：")
	style:setTFByIndex(4, (myInfo.miningLevel or "0"))
	local famousPersonValue = db:getFamousPersonValueByRank("mrt_hssl", myInfo.rank) or 0
	style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QRealtimeSilverMineRank
