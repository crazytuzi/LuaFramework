
local QBaseRank = import(".QBaseRank")
local QMetalAbyssWorldEnvRank = class("QMetalAbyssWorldEnvRank", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QUIViewController = import("..ui.QUIViewController")

function QMetalAbyssWorldEnvRank:ctor(options)
	QMetalAbyssWorldEnvRank.super.ctor(self, options)
end

function QMetalAbyssWorldEnvRank:needsUpdate( ... )
	return true
end

function QMetalAbyssWorldEnvRank:update(success, fail)
	app:getClient():top50RankRequest("ABYSS_STAR_ALL_TOP_50", remote.user.userId, function (data)
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

function QMetalAbyssWorldEnvRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QMetalAbyssWorldEnvRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:setTFByIndex(3, "搜索星数:")
		style:setTFByIndex(4, (info.abyssTotalStarCount or 0).."  ")
		style:setTFByIndex(5, "服务器名："..info.game_area_name)

		-- style:setTFByIndex(3, "通关最高关卡:")
		-- local curentFloorInfo = remote.metalCity:getMetalCityConfigByFloor(info.metalCityNum or 0)
		-- local chapterStr = curentFloorInfo.metalcity_chapter or 1
		-- local floorStr = curentFloorInfo.metalcity_floor or 0
		-- style:setTFByIndex(4, string.format(" %s-%s", chapterStr, floorStr))
		-- local famousPersonValue = db:getFamousPersonValueByRank("mrt_jszc", index) or 0
		-- style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)

		style._ccbOwner.sp_1:setVisible(false)
		style:autoLayout()
	end
end

function QMetalAbyssWorldEnvRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QMetalAbyssWorldEnvRank:clickHandler( x, y, touchNodeNode, list )
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		remote.metalAbyss:abyssQueryFighterRequest(info.userId, function(data)
			local fighter = (data.towerFightersDetail or {})[1]
	  		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfoThreeTeam",
	                options = {fighter = fighter, isPVP = true}}, {isPopCurrentDialog = false})
		end)
	end
end

function QMetalAbyssWorldEnvRank:getSelfItem()
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
	style:setTFByIndex(3, "搜索星数:")
	style:setTFByIndex(4, (myInfo.abyssTotalStarCount or 0).."  ")
	style:setTFByIndex(5, "服务器名："..myInfo.game_area_name)

	style._ccbOwner.sp_1:setVisible(false) 
	style:autoLayout()
	return item
end

return QMetalAbyssWorldEnvRank