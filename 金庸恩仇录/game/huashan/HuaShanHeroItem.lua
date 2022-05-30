local HuaShanHeroItem = class("HuaShanHeroItem", function()
	return CCTableViewCell:new()
end)

function HuaShanHeroItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_choose_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function HuaShanHeroItem:ctor()
end

function HuaShanHeroItem:create(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	local _info = param.info
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._bg = CCBuilderReaderLoad("huashan/huashan_choose_item.ccbi", proxy, self._rootnode)
	self._bg:setPosition(_viewSize.width / 2, 0)
	self:addChild(self._bg)
	self._icon = {}
	for i = 1, 5 do
		if _itemData[i] then
			self._icon[i] = require("game.Icon.IconObj").new({
			id = _itemData[i].resId,
			hp = _itemData[i].life and {
			_itemData[i].life,
			_itemData[i].initLife
			},
			level = _itemData[i].level,
			cls = _itemData[i].cls,
			state = _itemData[i].state
			})
		else
			self._icon[i] = require("game.Icon.IconObj").new({})
		end
		self._icon[i]:setPosition(self._icon[i]:getContentSize().width / 2, self._rootnode["headIcon_" .. tostring(i)]:getContentSize().height / 2)
		self._rootnode["headIcon_" .. tostring(i)]:addChild(self._icon[i])
		if self._icon[i]:getChildByTag(1000) ~= nil then
			self._icon[i]:getChildByTag(1000):removeFromParentAndCleanup(true)
		end
		if _info ~= nil and _info.cardId ~= nil and _itemData[i] ~= nil and _itemData[i].resId == _info.cardId then
			local suitArma = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "pinzhikuangliuguang_jin",
			isRetain = true
			})
			suitArma:setPosition(self._icon[i]:getContentSize().width / 2, self._icon[i]:getContentSize().height / 2 + 10)
			suitArma:setTouchEnabled(false)
			suitArma:setTag(1000)
			self._icon[i]:addChild(suitArma, 10000)
		end
	end
	self:refresh(param)
	return self
end

function HuaShanHeroItem:getIcon(index)
	return self._rootnode["headIcon_" .. tostring(index)]
end

function HuaShanHeroItem:refresh(param)
	local _itemData = param.itemData
	local _info = param.info
	for i = 1, 5 do
		if _itemData[i] then
			self._icon[i]:setVisible(true)
			self._icon[i]:refresh({
			id = _itemData[i].resId,
			state = _itemData[i].state,
			hp = _itemData[i].life and {
			_itemData[i].life,
			_itemData[i].initLife
			},
			level = _itemData[i].level,
			cls = _itemData[i].cls
			})
		else
			self._icon[i]:setVisible(false)
		end
		if self._icon[i]:getChildByTag(1000) ~= nil then
			self._icon[i]:getChildByTag(1000):removeFromParentAndCleanup(true)
		end
		if _info ~= nil and _info.cardId ~= nil and _itemData[i] ~= nil and _itemData[i].resId == _info.cardId then
			local suitArma = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "pinzhikuangliuguang_jin",
			isRetain = true
			})
			suitArma:setPosition(self._icon[i]:getContentSize().width / 2, self._icon[i]:getContentSize().height / 2 + 10)
			suitArma:setTouchEnabled(false)
			suitArma:setTag(1000)
			self._icon[i]:addChild(suitArma, 10000)
		end
	end
end

return HuaShanHeroItem