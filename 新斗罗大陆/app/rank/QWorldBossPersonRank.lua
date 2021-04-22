--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseRank = import(".QBaseRank")
local QWorldBossPersonRank = class("QWorldBossPersonRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleDurian = import("..ui.widgets.rank.QUIWidgetRankStyleDurian")
local QUIWidgetMyRankStyleDurian = import("..ui.widgets.rank.QUIWidgetMyRankStyleDurian")

function QWorldBossPersonRank:ctor(options)
	QWorldBossPersonRank.super.ctor(self, options)
end

function QWorldBossPersonRank:update(success, fail)
	--TODO: add response list
	remote.worldBoss:requestWorldBossRank("WORLD_BOSS_USER_HURT", remote.user.userId, function(data)
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
	    		local num,unit = q.convertLargerNumber(value.intrusionAllHurt)
	    		value.intrusionAllHurt = num..(unit or "")
			end
			self._myInfo = data.rankings.myself
			local num,unit = q.convertLargerNumber(self._myInfo.intrusionAllHurt)
			self._myInfo.intrusionAllHurt = num..(unit or "")

			self.super:update(success)
		end, fail)
end

function QWorldBossPersonRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleDurian.new()
	item:setStyle(style)
	return item
end

function QWorldBossPersonRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "个人荣誉：")
		style:setTFByIndex(4, "服务器名: ")
		style:setTFByIndex(5, info.intrusionAllHurt or 0)
		style:setTFByIndex(6, info.game_area_name or "")

		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:autoLayout()
	end
end

function QWorldBossPersonRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QWorldBossPersonRank:clickHandler( x, y, touchNodeNode, list )
	-- local info = self._list[list:getCurTouchIndex()]
	-- if info ~= nil then
	-- 	self:queryFighterWithRank(info.userId, {})
	-- end
end

function QWorldBossPersonRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleDurian.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	style:setTFByIndex(3, "个人荣誉：")
	style:setTFByIndex(4, (myInfo.intrusionAllHurt or "0"))
	style:autoLayout()
	return item
end

function QWorldBossPersonRank:getEmptySprite()
	return QWorldBossPersonRank.super.getEmptySprite(self, 4)
end

function QWorldBossPersonRank:setTips(node)
	node:setString("虚位以待，敬请期待！")
end

return QWorldBossPersonRank
