local HuaShanSelectItem = class("HuaShanSelectItem", function()
	return CCTableViewCell:new()
end)

function HuaShanSelectItem:getContentSize()
	return cc.size(114, 140)
end

function HuaShanSelectItem:ctor()
end

function HuaShanSelectItem:create(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	dump(_itemData)
	self._icon = require("game.Icon.IconObj").new({
	id = _itemData.resId
	})
	self._icon:setPosition(self:getContentSize().width / 2, _viewSize.height / 2 + 5)
	self:addChild(self._icon)
	self:refresh(param)
	return self
end

function HuaShanSelectItem:refresh(param)
	local _itemData = param.itemData
	self._icon:refresh({
	id = _itemData.resId,
	hp = _itemData.life and {
	_itemData.life,
	_itemData.initLife
	},
	level = _itemData.level,
	cls = _itemData.cls
	})
end
return HuaShanSelectItem