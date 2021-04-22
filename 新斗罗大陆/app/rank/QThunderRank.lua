--
-- Author: xurui
-- Date: 2015-08-11 10:10:47
--

local QBaseRank = import(".QBaseRank")
local QThunderRank = class("QThunderRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QThunderRank:ctor(options)
	QThunderRank.super.ctor(self, options)
end

function QThunderRank:update(success, fail)
	app:getClient():top50RankRequest("THUNDER_RANK_CURRENT", remote.user.userId, function (data)
	if data.thunderRankResponse == nil or data.thunderRankResponse.ranks == nil then 
		self.super:update(fail)
		return 
	end

	self._list = nil
	self._list = clone(data.thunderRankResponse.ranks)
	for k, v in ipairs(self._list) do
		v.avatar = v.icon
	end
	table.sort(self._list, function (x, y)
		return x.rank < y.rank
	end)
	self._myInfo = data.thunderRankResponse.myrank or {}

	self.super:update(success)
end, fail)
end


function QThunderRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QThunderRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "历史最高星级：")
		style:setTFByIndex(4, (info.starHisMax or "0"))
		style:setAvatar(info.avatar)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		local famousPersonValue = db:getFamousPersonValueByRank("mrt_slzd", index) or 0
		style:setTFByIndex(5, " 名人堂积分："..famousPersonValue)
		style:autoLayout()
	end
end

function QThunderRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QThunderRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryFighterWithRank(info.userId, {})
	end
end

function QThunderRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new({config = self._config})
	item:setInfo(myInfo)
	item:showAwardButton()
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.icon)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "历史最高星级：")
	style:setTFByIndex(4, (myInfo.starHisMax or "0"))
	local famousPersonValue = db:getFamousPersonValueByRank("mrt_slzd", myInfo.rank) or 0
	style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

function QThunderRank:checkRedTips()
	if remote.rank:checkAwardTipByType(self._config.awardType) then
		return true
	end

	return false
end

return QThunderRank