local ShopItem = class("ShopItem", function ()
	return CCTableViewCell:new()
end)

function ShopItem:getContentSize()
	return cc.size(display.width, 188)
end

function ShopItem:create(param)
	dump(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	local _idx = param.idx
	local _listener = param.buyListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("shop/shop_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self._rootnode.buyBtn:addHandleOfControlEvent(function (eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if _listener then
			_listener(self:getIdx())
		end
	end,
	CCControlEventTouchDown)
	self.itemName = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 26,
	--x = self._rootnode.itemNameLabel:getContentSize().width / 2,
	--y = self._rootnode.itemNameLabel:getContentSize().height / 2,
	color = FONT_COLOR.LEVEL_NAME,
	outlineColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLableEx(self.itemName, self._rootnode, "itemNameLabel", 0, 0)
	self.itemName:align(display.LEFT_CENTER)
	
	self:refreshLabel(_itemData)
	self:refresh(param)
	return self
end

function ShopItem:refreshLabel(itemData)
	self.itemName:setString(tostring(itemData.name))
	self._rootnode.descLabel:setString(tostring(itemData.desc))
	self._rootnode.costLabel:setString(tostring(itemData.price))
	if itemData.maxnum == -1 then
		self._rootnode.remainNumLabel:setVisible(false)
	else
		self._rootnode.remainNumLabel:setVisible(true)
		self._rootnode.remainNumLabel:setString(common:getLanguageString("@TodayLeftTime", itemData.remainnum))
	end
end

function ShopItem:refresh(param)
	local _itemData = param.itemData
	local _idx = param.idx
	local data_item_item = require("data.data_item_item")
	if data_item_item[_itemData.itemId].type == 6 then
		self._rootnode.tag_icon:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
		self._rootnode.tag_icon:removeAllChildrenWithCleanup(true)
		self._rootnode.tag_icon:addChild(require("game.Spirit.SpiritIcon").new({
		resId = _itemData.itemId
		}))
	else
		self._rootnode.tag_icon:removeAllChildrenWithCleanup(true)
		ResMgr.refreshIcon({
		itemBg = self._rootnode.tag_icon,
		id = _itemData.itemId,
		resType = ResMgr.ITEM
		})
	end
	self:refreshLabel(_itemData)
end

return ShopItem