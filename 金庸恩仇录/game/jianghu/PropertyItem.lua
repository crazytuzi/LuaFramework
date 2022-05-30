local data_item_nature = require("data.data_item_nature")

local PropertyItem = class("HeroGiftItem", function()
	return CCTableViewCell:new()
end)

function PropertyItem:getContentSize()
	return cc.size(211, 37)
end

function PropertyItem:create(param)
	local _viewSize = param.viewSize
	local _idx = param.idx
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._bg = CCBuilderReaderLoad("jianghulu/jianghulu_prop_item.ccbi", proxy, self._rootnode)
	self._bg:setPosition(_viewSize.width / 2, self._bg:getContentSize().height / 2)
	self:addChild(self._bg)
	self:refresh(param)
	return self
end

function PropertyItem:refresh(param)
	local _idx = param.idx
	local _itemData = param.itemData
	local _heroLv = param.heroLv
	self._bg:setDisplayFrame(display.newSpriteFrame(string.format("jianghulu_prop_%d.png", _idx % 2)))
	self._rootnode.needHeartLabel:setString(tostring(_idx))
	local nature = data_item_nature[_itemData.id]
	self._rootnode.nameLabel:setString(nature.nature)
	local str
	if nature.type == 1 then
		str = string.format("%d", _itemData.val)
	else
		str = string.format("%d%%", _itemData.val / 100)
	end
	self._rootnode.valueLabel:setString("+" .. str)
	if _idx > _heroLv then
		self._rootnode.valueLabel:setColor(cc.c3b(59, 29, 1))
		self._rootnode.iconSprite:setDisplayFrame(display.newSpriteFrame("jianghulu_love_1.png"))
		self._rootnode.needHeartLabel:setColor(cc.c3b(59, 29, 1))
	else
		self._rootnode.valueLabel:setColor(cc.c3b(147, 45, 40))
		self._rootnode.iconSprite:setDisplayFrame(display.newSpriteFrame("jianghulu_love.png"))
		self._rootnode.needHeartLabel:setColor(cc.c3b(147, 45, 40))
	end
	alignNodesOneByOne(self._rootnode.nameLabel, self._rootnode.valueLabel)
end

return PropertyItem