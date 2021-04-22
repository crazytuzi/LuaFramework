local QBaseRank = import(".QBaseRank")
local QUnionDragonRankWar = class("QUnionDragonRankWar", QBaseRank)
local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QUIWidgetMyRankStyleDurian = import("..ui.widgets.rank.QUIWidgetMyRankStyleDurian")

function QUnionDragonRankWar:ctor(options)
	QUnionDragonRankWar.super.ctor(self, options)
end

function QUnionDragonRankWar:needsUpdate( ... )
	return true
end

function QUnionDragonRankWar:update(success, fail)
	app:getClient():top50RankRequest("DRAGON_WAR_CONSORTIA_SCORE_TOP_10", remote.user.userId, function (data)
		if data.consortiaRankings == nil or data.consortiaRankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = nil
		self._list = clone(data.consortiaRankings.top50)
		for k, v in ipairs(self._list) do
			v.avatar = v.icon
		end
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)

		self._myInfo = data.consortiaRankings.myself
		self._myInfo.avatar = self._myInfo.icon
		if self._myInfo.rank == nil or self._myInfo.rank <= 0 then
			self._myInfo.rank = nil
		end

		self.super:update(success)
	end, fail)
end

function QUnionDragonRankWar:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QUnionDragonRankWar:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setUnionAvatar(info.icon, info.consortiaWarFloor)
		style:setVIP(nil)

		style:setTFByIndex(3, "争霸积分：")
		style:setTFByIndex(4, "服务器名：")
		style:setTFByIndex(5, info.consortiaScore or 0)
		style:setTFByIndex(6, info.gameAreaName)
		style:setTFByIndex(7, "")
		style:setSpByIndex(1, false)
		style:setSpByIndex(2, false)
		style:setSpByIndex(3, false)

		style:setFloor(info.consortiaFloor, 0.6, "unionDragonWar")
		local dragonConfig = db:getUnionDragonConfigById(info.dragonId)
		style:setTFByIndex(8, dragonConfig.name or "")

		style:autoLayout()
	end
end

function QUnionDragonRankWar:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleDurian.new()
	item:setStyle(style)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setUnionAvatar(myInfo.icon, myInfo.consortiaWarFloor)
	style:setVIP()
	style:setTFByIndex(3, "争霸积分：")
	style:setTFByIndex(4, myInfo.consortiaScore or "0")
	style:setTFByIndex(5, "")
	style:setFloor(myInfo.consortiaFloor, 0.6, "unionDragonWar")

	style:autoLayout()
	return item
end

return QUnionDragonRankWar