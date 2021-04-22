-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 20:48:02
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-14 16:31:07
local QBaseRank = import(".QBaseRank")
local QRealtimeSotoTeamRank = class("QRealtimeSotoTeamRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetRankStyleBanana = import("..ui.widgets.rank.QUIWidgetRankStyleBanana")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetMyRankStyleBanana = import("..ui.widgets.rank.QUIWidgetMyRankStyleBanana")
local QUIViewController = import("..ui.QUIViewController")

function QRealtimeSotoTeamRank:ctor(options)
	QRealtimeSotoTeamRank.super.ctor(self, options)
end

function QRealtimeSotoTeamRank:update(success, fail)
	app:getClient():top50RankRequest("SOTO_TEAM_ENV_TOP_50", remote.user.userId, function (data)
		if data.rankings == nil or data.rankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = clone(data.rankings.top50)
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		self._myInfo = data.rankings.myself

		self.super:update(success)
	end, fail)
end

function QRealtimeSotoTeamRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleBanana.new()
	item:setStyle(style)
	return item
end

function QRealtimeSotoTeamRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		--local famousPersonValue = db:getFamousPersonValueByRank("mrt_dhc", index) or 0
		--style:setTFByIndex(3, "名人堂积分："..famousPersonValue)

		style:autoLayout()
	end
end

function QRealtimeSotoTeamRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QRealtimeSotoTeamRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		local isEquilibrium = remote.sotoTeam:checkIsEquilibriumSeason()
		remote.sotoTeam:sotoTeamQueryFighterRequest(info.userId, function(data)
			local rivalInfo = (data.towerFightersDetail or {})[1] 
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
	    		options = {fighter = rivalInfo, forceTitle1 = "防守战力：", model = GAME_MODEL.NORMAL, isPVP = true, isEquilibrium = isEquilibrium}}, {isPopCurrentDialog = false})
		end)
	end
end

function QRealtimeSotoTeamRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleBanana.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)
	-- local famousPersonValue = db:getFamousPersonValueByRank("mrt_dhc", myInfo.rank) or 0
	-- style:setTFByIndex(3, "  名人堂积分："..famousPersonValue)

	style:autoLayout()
	return item
end


return QRealtimeSotoTeamRank
