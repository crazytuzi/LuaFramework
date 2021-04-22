--
-- Author: xurui
-- Date: 2016-06-30 11:03:37
--
local QBaseRank = import(".QBaseRank")
local QUnionDamageRank = class("QUnionDamageRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleCherry = import("..ui.widgets.rank.QUIWidgetRankStyleCherry")

function QUnionDamageRank:ctor(options)
	QUnionDamageRank.super.ctor(self, options)
end

function QUnionDamageRank:needsUpdate( ... )
	return true
end

function QUnionDamageRank:update(success, fail)
	app:getClient():top50RankRequest("CONSORTIA_BOSS_MEMBER_INFO", remote.user.userId, function (data)
			if data.rankings == nil or data.rankings.top50 == nil then 
				self.super:update(fail)
				return 
			end

			self._list = nil
			self._list = clone(data.rankings.top50)
			table.sort(self._list, function (x, y)
				return x.rank < y.rank
			end)
			-- if data.rankings.myself ~= nil then
			-- 	-- self._myInfo = data.rankings.myself
			-- 	self._myInfo.avatar = self._myInfo.icon
			-- else
			-- 	-- self._myInfo = remote.user:makeFighterByTeamKey(remote.teamManager.SOCIETYDUNGEON_ATTACK_TEAM)
			-- end
			self._myInfo = data.rankings.myself
			if self._myInfo then
				self._myInfo.avatar = self._myInfo.icon
			end
			self.super:update(success)
		end, fail)
end

function QUnionDamageRank:getEmptySprite()
	local node = CCNode:create()
	local paths = QResPath("rank_empty_tips")
	local sp1 = CCSprite:create(paths[1])
	sp1:setPosition(ccp(0, 0))
	node:addChild(sp1)
	return node
end

function QUnionDamageRank:setTips(node)
	node:setString("虚位以待，敬请期待！")
end

function QUnionDamageRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleCherry.new()
	item:setStyle(style)
	return item
end

function QUnionDamageRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip)
		style:setTFByIndex(3, "累计伤害：")
		local num, word = q.convertLargerNumber(info.consortiaBossAllDamage or 0)
		style:setTFByIndex(4, num..(word or "").."  ")
		style:setTFByIndex(5, "攻打次数：")
		style:setTFByIndex(6, info.consortiaBossFightCount or 0)
		style:autoLayout()
	end
end

function QUnionDamageRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QUnionDamageRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryFighterWithRank(info.userId, {})
	end
end

return QUnionDamageRank
