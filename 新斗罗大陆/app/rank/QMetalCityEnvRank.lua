-- @Author: xurui
-- @Date:   2018-08-15 18:10:21
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-16 18:46:28
local QBaseRank = import(".QBaseRank")
local QMetalCityEnvRank = class("QMetalCityEnvRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QUIViewController = import("..ui.QUIViewController")

function QMetalCityEnvRank:ctor(options)
	QMetalCityEnvRank.super.ctor(self, options)
end

function QMetalCityEnvRank:needsUpdate( ... )
	return true
end

function QMetalCityEnvRank:update(success, fail)
	app:getClient():top50RankRequest("METAL_CITY_REALTIME_TOP_50", remote.user.userId, function (data)
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

function QMetalCityEnvRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QMetalCityEnvRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)

		style:setTFByIndex(3, "通关最高关卡:")
		local curentFloorInfo = remote.metalCity:getMetalCityConfigByFloor(info.metalCityNum or 0)
		local chapterStr = curentFloorInfo.metalcity_chapter or 1
		local floorStr = curentFloorInfo.metalcity_floor or 0
		style:setTFByIndex(4, string.format(" %s-%s", chapterStr, floorStr))
		local famousPersonValue = db:getFamousPersonValueByRank("mrt_jszc", index) or 0
		style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

		style._ccbOwner.sp_1:setVisible(false)
		style:autoLayout()
	end
end

function QMetalCityEnvRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QMetalCityEnvRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryFighterWithRank(info.userId, {})
	end
end

function QMetalCityEnvRank:getSelfItem()
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

	style:setTFByIndex(3, "通关最高关卡:")
	local curentFloorInfo = remote.metalCity:getMetalCityConfigByFloor(myInfo.metalCityNum or 1)
	local chapterStr = curentFloorInfo.metalcity_chapter or 1
	local floorStr = curentFloorInfo.metalcity_floor or 0
	style:setTFByIndex(4, string.format(" %s-%s", chapterStr, floorStr))
	local famousPersonValue = db:getFamousPersonValueByRank("mrt_jszc", myInfo.rank) or 0
	style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

	style._ccbOwner.sp_1:setVisible(false) 
	style:autoLayout()
	return item
end

return QMetalCityEnvRank