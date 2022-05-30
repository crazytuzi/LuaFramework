local data_field_field = require("data.data_field_field")
local data_battle_battle = require("data.data_battle_battle")
local data_world_world = require("data.data_world_world")

local RankListCell = class("RankListCell", function()
	return CCTableViewCell:new()
end)
local MAX_ZORDER = 100000

function RankListCell:getContentSize()
	return cc.size(display.width, self._rootnode.itemBg:getContentSize().height)
end

function RankListCell:refresh(id)
	self:refreshCellData(id)
	self:refreshCellContent()
end

function RankListCell:refreshCellData(id)
	local listData = RankListModel.getList(self.cellType)
	local cellData = listData[id]
	self.cellData = cellData
	self.index = id
	self.name = cellData.name or 0
	self.account = cellData.account
	self.battlepoint = cellData.attack or 0
	self.resId = cellData.resId or 0
	self.cls = cellData.cls or 1
	self.roleId = cellData.roleId or 0
	self.rank = cellData.rank or 0
	self.gonghui = cellData.faction
	self.grade = cellData.grade or 0
	self.battleStars = cellData.battleStars or 0
	self.battleId = cellData.battleId or 5
end

function RankListCell:refreshCellContent()
	local rankKey = 4
	if 4 > self.rank and self.rank > 0 then
		rankKey = self.rank
	end
	for i = 1, 4 do
		if i == rankKey then
			self._rootnode["lvl_" .. i .. "_node"]:setVisible(true)
		else
			self._rootnode["lvl_" .. i .. "_node"]:setVisible(false)
		end
	end
	local heroNameColor
	if rankKey == 1 then
		heroNameColor = cc.c3b(239, 100, 255)
	elseif rankKey == 2 then
		heroNameColor = cc.c3b(0, 234, 247)
	elseif rankKey == 3 then
		heroNameColor = cc.c3b(36, 255, 0)
	else
		heroNameColor = cc.c3b(255, 255, 255)
	end
	self.heroNameTTF:setString(self.name)
	self.heroNameTTF:setColor(heroNameColor)
	self.zhanliTTF:setString(self.battlepoint)
	ResMgr.refreshIcon({
	id = self.resId,
	itemBg = self._rootnode.headIcon,
	resType = ResMgr.HERO,
	cls = self.cls
	})
	local fontSize = 42
	if self.rank > 9 and self.rank < 100 then
		fontSize = 32
	elseif self.rank > 99 then
		fontSize = 26
	end
	self.rankTTF = ResMgr.createShadowMsgTTF({
	text = self.rank,
	color = cc.c3b(251, 239, 197),
	size = fontSize
	})
	self.rankTTF:align(display.CENTER, self._rootnode.rank_icon_bg:getContentSize().width / 2,  self._rootnode.rank_icon_bg:getContentSize().height / 2)
	self.rankTTFNode:removeAllChildren()
	self.rankTTFNode:addChild(self.rankTTF)
	if self.gonghui ~= nil and self.gonghui ~= "" then
		self.gonghuiNameTTF:setString("[" .. self.gonghui .. "]")
		self.heroNameTTF:setPosition(self.nameOrPos)
		self._rootnode.lvl_icon:setPosition(self.lvOrPos)
	else
		self.gonghuiNameTTF:setString("")
		self.heroNameTTF:setPosition(self.nameMidPos)
		self._rootnode.lvl_icon:setPosition(self.lvMidPos)
	end
	self.lvlTTF:setString(self.grade)
	self.lvlTTF:setPosition(self._rootnode.lvl_icon:getPositionX() + self._rootnode.lvl_icon:getContentSize().width, self._rootnode.lvl_icon:getPositionY())
	self.starNumTTF:setString(self.battleStars)
	if self.battleId ~= 0 then
		local fieldName = data_field_field[data_battle_battle[self.battleId].field].name
		local str = tostring(self.battleId)
		str = string.sub(str, string.len(str) - 1, string.len(str))
		local curNum = tonumber(str)
		self._rootnode.fuben_name:setString(fieldName .. curNum)
	end
end

function RankListCell:ctor()
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("rankList/rank_scene_cell.ccbi", proxy, self._rootnode)
	self.baseNode = node
	self.baseNode:setPosition(display.width * 0.47, self._rootnode.itemBg:getContentSize().height)
	self:addChild(node)
end

function RankListCell:mirrorPos(target, curNode)
	target:getParent():addChild(curNode)
end

function RankListCell:create(param)
	self.cellType = param.cellType
	if self.cellType == 3 then
		self._rootnode.jindu_node:setVisible(true)
		self._rootnode.zhanli_node:setVisible(false)
	else
		self._rootnode.jindu_node:setVisible(false)
		self._rootnode.zhanli_node:setVisible(true)
	end
	self.heroNameTTF = ResMgr.createShadowMsgTTF({
	text = "",
	color = cc.c3b(0, 0, 0),
	size = 24
	})
	self._rootnode.hero_name:getParent():addChild(self.heroNameTTF)
	self.gonghuiNameTTF = ResMgr.createShadowMsgTTF({
	text = "",
	color = cc.c3b(255, 222, 0),
	size = 24
	})
	self._rootnode.gonghui_name:getParent():addChild(self.gonghuiNameTTF)
	self.gonghuiNameTTF:setPosition(ccp(self._rootnode.gonghui_name:getPositionX(), self._rootnode.gonghui_name:getPositionY()))
	self.lvlTTF = ResMgr.createShadowMsgTTF({
	text = "",
	color = cc.c3b(255, 222, 0),
	size = 22
	})
	self._rootnode.level:getParent():addChild(self.lvlTTF)
	self.tableViewRect = param.tableViewRect
	self._rootnode.jianghu:setString(common:getLanguageString("@jianghujd"))
	
	self.rankTTFNode = display.newNode()
	self._rootnode.rank_icon_bg:addChild(self.rankTTFNode)
	self.zhanliTTF = ResMgr.createShadowMsgTTF({
	text = "",
	color = cc.c3b(36, 255, 0),
	size = 24
	})
	self._rootnode.zhanli_num:getParent():addChild(self.zhanliTTF)
	self.zhanliTTF:setPosition(ccp(self._rootnode.zhanli_num:getPositionX(), self._rootnode.zhanli_num:getPositionY()))
	self.starNumTTF = self._rootnode.jindu_num
	local fubenColor = cc.c3b(0, 234, 247)
	self.lvOrPos = cc.p(self._rootnode.lvl_icon:getPositionX(), 93)
	self.nameOrPos = cc.p(self._rootnode.hero_name:getPositionX(), 62)
	self.lvMidPos = cc.p(self._rootnode.lvl_icon:getPositionX(), 80)
	self.nameMidPos = cc.p(self._rootnode.hero_name:getPositionX(), 44)
	self:refresh(param.id)
	return self
end

function RankListCell:tableCellTouched(x, y)
	local icon = self._rootnode.headIcon
	local size = icon:getContentSize()
	if cc.rectContainsPoint(cc.rect(0, 0, size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
		self:createDetailBox()
	end
end

function RankListCell:createDetailBox()
	local applyBox = require("game.RankListScene.RankListDetailBox").new(self.cellData)
	display.getRunningScene():addChild(applyBox, BOX_ZORDER.BASE)
end

return RankListCell