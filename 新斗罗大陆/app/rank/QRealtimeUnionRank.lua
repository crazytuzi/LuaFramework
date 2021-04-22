--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QRealtimeUnionRank = class("QRealtimeUnionRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleBanana = import("..ui.widgets.rank.QUIWidgetRankStyleBanana")
local QUIWidgetMyRankStyleBanana = import("..ui.widgets.rank.QUIWidgetMyRankStyleBanana")

function QRealtimeUnionRank:ctor(options)
	QRealtimeUnionRank.super.ctor(self, options)
end

function QRealtimeUnionRank:needsUpdate( ... )
	return true
end

function QRealtimeUnionRank:update(success, fail)
	app:getClient():top50RankRequest("CONSORTIA_LEVEL", remote.user.userId, function (data)
		if data.consortiaRankings == nil or data.consortiaRankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = nil
		self._list = clone(data.consortiaRankings.top50) or {}
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


function QRealtimeUnionRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleBanana.new()
	item:setStyle(style)
	return item
end

function QRealtimeUnionRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setUnionAvatar(info.icon, info.consortiaWarFloor)
		style:setVIP(nil)
		style:setTFByIndex(3, "")
		style:autoLayout()
	end
end

function QRealtimeUnionRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QRealtimeUnionRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryUnionWithRank(info.sid, {})
	end
end

function QRealtimeUnionRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if q.isEmpty(myInfo) then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleBanana.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setTFByIndex(3, "")
	style:setUnionAvatar(myInfo.icon, myInfo.consortiaWarFloor)

	style:autoLayout()
	return item
end


return QRealtimeUnionRank
