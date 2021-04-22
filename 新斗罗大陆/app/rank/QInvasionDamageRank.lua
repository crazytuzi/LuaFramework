--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QInvasionDamageRank = class("QInvasionDamageRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QInvasionDamageRank:ctor(options)
	QInvasionDamageRank.super.ctor(self, options)
end

function QInvasionDamageRank:update(success, fail)
	--TODO: add response list
	app:getClient():top50RankRequest("INTRUSION_MAX_HURT", remote.user.userId, function (data)
		if data.rankings == nil or data.rankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = nil
		self._list = clone(data.rankings.top50)
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		for _,value in ipairs(self._list) do
    		local num,unit = q.convertLargerNumber(value.intrusionMaxHurt)
    		value.intrusionMaxHurt = num..(unit or "")
		end
		self._myInfo = data.rankings.myself
		local num,unit = q.convertLargerNumber(self._myInfo.intrusionMaxHurt)
		self._myInfo.intrusionMaxHurt = num..(unit or "")

		self.super:update(success)
	end, fail)
end

function QInvasionDamageRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QInvasionDamageRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "当日最大伤害：")
		style:setTFByIndex(4, (info.intrusionMaxHurt or "0"))
		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:autoLayout()
	end
end

function QInvasionDamageRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QInvasionDamageRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryFighterWithRank(info.userId, {})
	end
end

function QInvasionDamageRank:getSelfItem()
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
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "当日最大伤害：")
	style:setTFByIndex(4, (myInfo.intrusionMaxHurt or "0"))
	style:setTFByIndex(5, "")
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

function QInvasionDamageRank:getEmptySprite()
	return QInvasionDamageRank.super.getEmptySprite(self, 4)
end

function QInvasionDamageRank:setTips(node)
	node:setString("虚位以待，敬请期待！")
end

function QInvasionDamageRank:checkRedTips()
	if remote.rank:checkAwardTipByType(self._config.awardType) then
		return true
	end

	return false
end

return QInvasionDamageRank
