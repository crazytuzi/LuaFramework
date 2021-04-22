--
-- Author: xurui
-- Date: 2016-06-30 11:02:08
--
local QBaseRank = import(".QBaseRank")
local QUnionDungeonRank = class("QUnionDungeonRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleCherry = import("..ui.widgets.rank.QUIWidgetRankStyleCherry")
local QUIWidgetMyRankStyleCherry = import("..ui.widgets.rank.QUIWidgetMyRankStyleCherry")

function QUnionDungeonRank:ctor(options)
	QUnionDungeonRank.super.ctor(self, options)
end

function QUnionDungeonRank:needsUpdate( ... )
	return true
end

function QUnionDungeonRank:update(success, fail)
	app:getClient():top50RankRequest("CONSORTIA_BOSS_TOP_CHAPTER", remote.user.userId, function (data)
		if data.consortiaRankings == nil or data.consortiaRankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = nil
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

		self.super:update(success)
	end, fail)
end

function QUnionDungeonRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleCherry.new()
	item:setStyle(style)
	return item
end

function QUnionDungeonRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setUnionAvatar(info.icon, info.consortiaWarFloor)
		style:setVIP(nil)
		style:setTFByIndex(4, "章节进度：")
		style:setTFByIndex(5, string.format("第%s章", info.max_chapter))
		style:setTFByIndex(6, info.max_chapter_progress.."%")
		style:autoLayout()
	end
end

function QUnionDungeonRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QUnionDungeonRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryUnionWithRank(info.sid, {})
	end
end

function QUnionDungeonRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if q.isEmpty(myInfo) then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleCherry.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setUnionAvatar(myInfo.icon, myInfo.consortiaWarFloor)

	style:setTFByIndex(3, "最高章节：")
	style:setTFByIndex(4, "章节进度：")
	style:setTFByIndex(5, string.format("第%s章", myInfo.max_chapter or 0))
	style:setTFByIndex(6, (myInfo.max_chapter_progress or 0).."%")
	style:setTFByIndex(7, "")

	style:autoLayout()
	return item
end


return QUnionDungeonRank
