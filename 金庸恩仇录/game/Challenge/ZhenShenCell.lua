local ZhenShenCell = class("ZhenShenCell", function()
	return CCTableViewCell:new()
end)

function ZhenShenCell:getContentSize()
	return cc.size(display.width, 212)
end

function ZhenShenCell:getIsAllowPlay()
	return self.isAllowPlay
end

function ZhenShenCell:getNode(index)
	return self._rootnode["node_" .. index]
end

function ZhenShenCell:refresh(param)
	self.cellData1 = param.data_1
	self.cellData2 = param.data_2
	local data_zhenshenfuben_zhenshenfuben = require("data.data_zhenshenfuben_zhenshenfuben")
	if self.sprite_2 ~= nil and self.cellData2 ~= nil then
		self._rootnode.node_2:setVisible(true)
		local data = data_zhenshenfuben_zhenshenfuben[self.cellData2.fbId]
		local spriteName = data.icon
		local nodeCell = self._rootnode.sprite_2
		self.sprite_2:setDisplayFrame(display.newSprite("hero/large/" .. spriteName .. ".png"):getDisplayFrame())
		self.sprite_2:setPosition(cc.p(nodeCell:getContentSize().width / 2 + data.cutX, nodeCell:getContentSize().height / 2 + data.cutY))
		self._rootnode.name_2:setString(data.name)
		if self.cellData2.battleState == 1 then
			self._rootnode.layer_2:setVisible(false)
		else
			self._rootnode.layer_2:setVisible(true)
		end
		if data.battle_point then
			self._rootnode.battleNode_2:setVisible(true)
			self._rootnode.battlePoint_2:setString(common:getLanguageString("@SuggestionFighting") .. data.battle_point)
		else
			self._rootnode.battleNode_2:setVisible(false)
		end
	else
		self._rootnode.node_2:setVisible(false)
	end
	if self.sprite_1 ~= nil and self.cellData1 ~= nil then
		local data = data_zhenshenfuben_zhenshenfuben[self.cellData1.fbId]
		local spriteName = data.icon
		local nodeCell = self._rootnode.sprite_1
		self._rootnode.node_1:setVisible(true)
		self.sprite_1:setDisplayFrame(display.newSprite("hero/large/" .. spriteName .. ".png"):getDisplayFrame())
		self.sprite_1:setPosition(cc.p(nodeCell:getContentSize().width / 2 + data.cutX, nodeCell:getContentSize().height / 2 + data.cutY))
		self._rootnode.name_1:setString(data.name)
		if self.cellData1.battleState == 1 then
			self._rootnode.layer_1:setVisible(false)
		else
			self._rootnode.layer_1:setVisible(true)
		end
		if data.battle_point then
			self._rootnode.battleNode_1:setVisible(true)
			self._rootnode.battlePoint_1:setString(common:getLanguageString("@SuggestionFighting") .. data.battle_point)
		else
			self._rootnode.battleNode_1:setVisible(false)
		end
	else
		self._rootnode.node_1:setVisible(false)
	end
end

function ZhenShenCell:isExist(index)
	return self._rootnode["node_" .. index]:isVisible()
end

function ZhenShenCell:create(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("challenge/challenge_zhenshen_item.ccbi", proxy, self._rootnode)
	self:addChild(node)
	self.cellData1 = param.data_1
	self.cellData2 = param.data_2
	self._rootnode.node_1:setVisible(false)
	self._rootnode.node_2:setVisible(false)
	local data_zhenshenfuben_zhenshenfuben = require("data.data_zhenshenfuben_zhenshenfuben")
	local SPACE = 7
	local SPACE_WIDTH = 14
	if self.cellData2 ~= nil then
		self._rootnode.node_2:setVisible(true)
		local data = data_zhenshenfuben_zhenshenfuben[self.cellData2.fbId]
		local spriteName = data.icon
		local nodeCell = self._rootnode.sprite_2
		local clippingNode = CCClippingNode:create()
		local size = nodeCell:getContentSize()
		clippingNode:setContentSize(size)
		local stencil = display.newRect(cc.rect(0, 0, size.width, size.height))
		stencil:setPosition(cc.p(0,0))
		stencil:setAnchorPoint(cc.p(0, 0))
		clippingNode:setStencil(stencil)
		clippingNode:setInverted(false)
		clippingNode:setPosition(cc.p(0, 0))
		self.sprite_2 = display.newSprite("hero/large/" .. spriteName .. ".png")
		self.sprite_2:align(display.CENTER, size.width / 2, size.height / 2)
		clippingNode:addChild(self.sprite_2)
		nodeCell:addChild(clippingNode)
	end
	
	if self.cellData1 ~= nil then
		self._rootnode.node_1:setVisible(true)
		local nodeCell = self._rootnode.sprite_1
		local data = data_zhenshenfuben_zhenshenfuben[self.cellData1.fbId]
		local spriteName = data.icon
		local clippingNode = CCClippingNode:create()
		local size = nodeCell:getContentSize()
		clippingNode:setContentSize(size)
		local stencil = display.newRect(cc.rect(0, 0, size.width, size.height))
		stencil:setPosition(cc.p(0,0))
		stencil:setAnchorPoint(cc.p(0, 0))
		clippingNode:setStencil(stencil)
		clippingNode:setInverted(false)
		clippingNode:setPosition(cc.p(0, 0))
		self.sprite_1 = display.newSprite("hero/large/" .. spriteName .. ".png")
		self.sprite_1:align(display.CENTER, size.width / 2, size.height / 2)
		clippingNode:addChild(self.sprite_1)
		nodeCell:addChild(clippingNode)
		self:refresh(param)
	end
	return self
end

return ZhenShenCell