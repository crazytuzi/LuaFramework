-- @Author: liaoxianbo
-- @Date:   2020-04-09 11:34:19
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-20 18:39:55
local QBaseRank = import(".QBaseRank")
local QSoulTowerAllServerRank = class("QSoulTowerAllServerRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QSoulTowerAllServerRank:ctor(options)
	QSoulTowerAllServerRank.super.ctor(self, options)
end

function QSoulTowerAllServerRank:needsUpdate( ... )
	return true
end

function QSoulTowerAllServerRank:update(success, fail)
	app:getClient():top50RankRequest("SOUL_TOWER_TOP_50", remote.user.userId, function (data)
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

function QSoulTowerAllServerRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QSoulTowerAllServerRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:setTFByIndex(3, "最高击退：")
		style:setTFByIndex(4, "击退时间：")
		style:setTFByIndex(5, (info.dungeonId or 0).."-"..(info.wave or 0))
		local passTime = string.format("%0.2f秒", tonumber(info.passTime or 0) / 1000.0 )	
		style:setTFByIndex(6, passTime)
		style:setTFByIndex(7, "")
		style:autoLayout()
	end
end

function QSoulTowerAllServerRank:getSelfItem()
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

	style:setTFByIndex(3, "最高击退：")
	style:setTFByIndex(4, (myInfo.dungeonId or 0).."-"..(myInfo.wave or 0))
	local passTime = string.format("%0.2f秒", tonumber(myInfo.passTime or 0) / 1000.0 )	
	style:setTFByIndex(5, "  击退时间："..passTime)
	style:autoLayout()
	style:setHideStart(true)
	return item
end

return QSoulTowerAllServerRank
