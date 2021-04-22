--
-- Author: xurui
-- Date: 2016-06-30 11:02:08
--
local QBaseRank = import(".QBaseRank")
local QWorldBossUnionRank = class("QWorldBossUnionRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QUIWidgetMyRankStyleCherry = import("..ui.widgets.rank.QUIWidgetMyRankStyleCherry")

function QWorldBossUnionRank:ctor(options)
	QWorldBossUnionRank.super.ctor(self, options)
end

function QWorldBossUnionRank:needsUpdate( ... )
	return true
end

function QWorldBossUnionRank:update(success, fail)
	remote.worldBoss:requestWorldBossRank("WORLD_BOSS_CONSORTIA_HURT_TOP_50", remote.user.userId, function(data)
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

			for _,value in ipairs(self._list) do
	    		local num,unit = q.convertLargerNumber(value.worldBossHurt)
	    		value.worldBossHurt = num..(unit or "")
			end
			self._myInfo = data.consortiaRankings.myself
			local num,unit = q.convertLargerNumber(self._myInfo.worldBossHurt)
			self._myInfo.worldBossHurt = num..(unit or "")

			self._myInfo = data.consortiaRankings.myself
			self._myInfo.avatar = self._myInfo.icon

			self.super:update(success)
		end, fail)
end

function QWorldBossUnionRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QWorldBossUnionRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setUnionAvatar(info.icon, info.consortiaWarFloor)
		style:setVIP(nil)
		style:setTFByIndex(3, "宗门荣誉：")
		style:setTFByIndex(4, "服务器名: ")
		style:setTFByIndex(5, info.worldBossHurt or 0)
		style:setTFByIndex(6, info.gameAreaName or "")

		style:autoLayout()
	end
end

function QWorldBossUnionRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QWorldBossUnionRank:clickHandler( x, y, touchNodeNode, list)
	-- local info = self._list[list:getCurTouchIndex()]
	-- if info ~= nil then
	-- 	self:queryUnionWithRank(info.sid, {})
	-- end
end

function QWorldBossUnionRank:getSelfItem()
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
	style:setUnionAvatarPosition(0, -20)

	style:setTFByIndex(3, "宗门荣誉：")
	style:setTFByIndex(4, (myInfo.worldBossHurt or "0"))

	style:autoLayout()
	return item
end


return QWorldBossUnionRank
