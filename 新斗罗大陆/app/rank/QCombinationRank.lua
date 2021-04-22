--
-- Author: xurui
-- Date: 2016-05-17 11:39:38
--
local QBaseRank = import(".QBaseRank")
local QCombinationRank = class("QCombinationRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QCombinationRank:ctor(options)
	QCombinationRank.super.ctor(self, options)
end

function QCombinationRank:update(success, fail)
	--TODO: add response list
	app:getClient():top50RankRequest("HERO_COMBINATION", remote.user.userId, function (data)
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

function QCombinationRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QCombinationRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "宿命激活数：")
		style:setTFByIndex(4, (info.combinationCount or "0"))
		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		local famousPersonValue = db:getFamousPersonValueByRank("mrt_sm", index) or 0
		style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

		style:autoLayout()
	end
end

function QCombinationRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QCombinationRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryFighterWithRank(info.userId, {})
	end
end

function QCombinationRank:getSelfItem()
	local item = QUIWidgetTeamMyRank.new()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "宿命激活数：")
	style:setTFByIndex(4, (myInfo.combinationCount or "0"))
	local famousPersonValue = db:getFamousPersonValueByRank("mrt_sm", myInfo.rank) or 0
	style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QCombinationRank