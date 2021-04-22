-- @Author: xurui
-- @Date:   2017-02-10 11:03:26
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-17 09:53:32
local QBaseRank = import(".QBaseRank")
local QUnionDragonRank = class("QUnionDragonRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleCherry = import("..ui.widgets.rank.QUIWidgetRankStyleCherry")

function QUnionDragonRank:ctor(options)
	QUnionDragonRank.super.ctor(self, options)
end

function QUnionDragonRank:needsUpdate( ... )
	return true
end

function QUnionDragonRank:update(success, fail)
	app:getClient():top50RankRequest("CONSORTIA_DRAGON_LEVEL_TOP_50", remote.user.userId, function (data)
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

	self.super:update(success)
end, fail)
end

function QUnionDragonRank:getEmptySprite()
	local node = CCNode:create()
	local paths = QResPath("rank_empty_tips")
	local sp1 = CCSprite:create(paths[1])
	sp1:setPosition(ccp(0, 0))
	node:addChild(sp1)
	return node
end

function QUnionDragonRank:setTips(node)
	node:setString("虚位以待，敬请期待！")
end

function QUnionDragonRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleCherry.new()
	item:setStyle(style)
	return item
end

function QUnionDragonRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setUnionAvatar(info.avatar, info.consortiaWarFloor)
		style:setVIP(info.vip)
		style:setTFByIndex(3, "武魂等级：")
		local dragonInfo = db:getUnionDragonInfoByLevel(info.dragonLevel)
		style:setTFByIndex(5, "LV."..(info.dragonLevel or 1).." (经验："..info.dragonExp.."/"..dragonInfo.exp..")")
		style:setTFByIndex(4, "")
		style:setTFByIndex(6, "")
		style:autoLayout()

		local nodes = {}
		table.insert(nodes, style:getChildByName("tf_3"))
		table.insert(nodes, style:getChildByName("tf_5"))
		q.autoLayerNode(nodes, "x")
	end
end

return QUnionDragonRank