--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 
local QBaseRank = import(".QBaseRank")
local QSunWarRank = class("QSunWarRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QSunWarRank:ctor(options)
	QSunWarRank.super.ctor(self, options)
end

function QSunWarRank:update(success, fail)
	--TODO: add response list
	app:getClient():top50RankRequest("BATTLEFIELD_TOP_WAVE", remote.user.userId, function (data)
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

function QSunWarRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QSunWarRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "历史最高：")
		local waveInfo = remote.sunWar:getWaveInfoByWaveID( info.battlefieldHisTopWave or 1, false) or {}
		local mapInfo = remote.sunWar:getMapInfoByMapID(waveInfo.chapter or 0) or {}
		style:setTFByIndex(4, string.format("%s%d-%d",mapInfo.name or "尚未通关关卡", waveInfo.chapter or 0,waveInfo.index or 0))
		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		local famousPersonValue = db:getFamousPersonValueByRank("mrt_hsd", index) or 0
		style:setTFByIndex(5, " 名人堂积分："..famousPersonValue)
		style:autoLayout()
	end
end

function QSunWarRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QSunWarRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then 
		local options = {}
		options.isPVP = true
		self:queryFighterWithRank(info.userId, options)
	end
end

function QSunWarRank:getSelfItem()
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

	style:setTFByIndex(3, "历史最高：")
	local waveInfo = remote.sunWar:getWaveInfoByWaveID(myInfo.battlefieldHisTopWave or 1, false) or {}
	local mapInfo = remote.sunWar:getMapInfoByMapID(waveInfo.chapter or 0) or {}
	style:setTFByIndex(4, string.format("%s%d-%d",mapInfo.name or "尚未通关关卡", waveInfo.chapter or 0,waveInfo.index or 0))
	local famousPersonValue = db:getFamousPersonValueByRank("mrt_hsd", myInfo.rank) or 0
	style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

function QSunWarRank:checkRedTips()
	if remote.rank:checkAwardTipByType(self._config.awardType) then
		return true
	end

	return false
end

return QSunWarRank


