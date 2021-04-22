--
-- Author: xurui
-- Date: 2015-10-22 17:07:59
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStoreAwardsBox = class("QUIWidgetStoreAwardsBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText")

QUIWidgetStoreAwardsBox.EVENT_CLICK_AWARDS_BOX = "EVENT_CLICK_AWARDS_BOX"

function QUIWidgetStoreAwardsBox:ctor(options)
	local ccbFile = "ccb/Widget_shop_award.ccbi"
	local callBack = {
		{ccbCallbackName = "onTirggerClick", callback = handler(self, QUIWidgetStoreAwardsBox._onTirggerClick)}
	}
	QUIWidgetStoreAwardsBox.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self._nameMaxSize = self._ccbOwner.node_name_size:getContentSize().width
	self._tipsMaxSizeWidth = self._ccbOwner.node_tips_size:getContentSize().width
	self._tipsMaxSizeHeight = self._ccbOwner.node_tips_size:getContentSize().height
	self:resetAll()
end

function QUIWidgetStoreAwardsBox:resetAll()
	self._ccbOwner.sp_partition:setVisible(false)
	self._ccbOwner.node_sale:setVisible(false)
	self._ccbOwner.ly_empty:setVisible(false)
	self._ccbOwner.sp_empty:setVisible(false)
	self._ccbOwner.node_price:setVisible(true)
	self._ccbOwner.node_price_1:setVisible(false)
	self._ccbOwner.node_price_2:setVisible(false)

	self._ccbOwner.node_goods_name:removeAllChildren()
	self._ccbOwner.node_tips:removeAllChildren()

	self.isSell = false
	self._canSell = false
end

function QUIWidgetStoreAwardsBox:setItmeBox(shopInfo, awards)
	if shopInfo == nil then return end
	self:resetAll()

	self._shopInfo = shopInfo
	self._awards = awards

	if self._itemBox ~= nil then
		self._itemBox:removeFromParent()
		self._itemBox = nil
	end

	local awardsInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(self._awards.good_id)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(awardsInfo.id_1)

	self._ccbOwner.node_itembox:removeAllChildren()
	self._itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.node_itembox:addChild(self._itemBox)
	self._itemBox:setGoodsInfo(awardsInfo.id_1, awardsInfo.type_1, awardsInfo.num_1)

	local name = ""
	if awardsInfo.id_1 ~= nil then
		name = itemInfo.name
	elseif awardsInfo.type_1 ~= "item" then
		itemInfo = remote.items:getWalletByType(awardsInfo.type_1)
		name = itemInfo.nativeName
	end

	-- 设置货物名字、颜色、大小
	local fontColor = COLORS.w
	local shadowColor = COLORS.Y
	if itemInfo.colour ~= nil and remote.stores.itemQualityIndex[tonumber(itemInfo.colour)] ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[remote.stores.itemQualityIndex[tonumber(itemInfo.colour)]]
		shadowColor = getShadowColorByFontColor(fontColor)
	end
	local nameRichText = QRichText.new("", nil, {stringType = 1, defaultColor = fontColor, strokeColor = shadowColor, defaultSize = 24})
	nameRichText:setString(name)
	local nameWidth = nameRichText:getCascadeBoundingBox().size.width
	nameRichText:setScale(1)
	if nameWidth > self._nameMaxSize then
		nameRichText:setScale( 1 - (nameWidth - self._nameMaxSize) / self._nameMaxSize )
	end
	nameRichText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_goods_name:addChild(nameRichText)

	self._ccbOwner.tf_price_1:setString(awardsInfo.money_num_1 or 0)
	self:setCurrencyIcon()
	self._ccbOwner.node_price_1:setVisible(true)

	self._itemInfo = {id = awardsInfo.id_1, itemType = awardsInfo.type_1, count = awardsInfo.num_1, position = self._awards.position-1, moneyType = self._shopInfo.currencyType, cost = awardsInfo.money_num_1 or 0}

	local sellInfo = remote.stores:getAwardsShopById(tostring(self._awards.shop_id))
	if sellInfo ~= nil or sellInfo ~= "" then 
		sellInfo = string.split(sellInfo, ";")
		for i = 1, #sellInfo, 1 do
			if tonumber(sellInfo[i]) == self._awards.position-1 then
				self:_setItemIsSell()
			end
		end
	end
	
	self:setConditionBar(awardsInfo)
	if awardsInfo.money_discount_1 then
		self:setDazheType(awardsInfo.money_discount_1 * 10 or 0, 4)
	end
end

function QUIWidgetStoreAwardsBox:setDazheType( int, colorType )
	if tonumber(int) > 0 then
		if not colorType then colorType = 0 end
		self._ccbOwner.lanDisCountBg:setVisible(false)
		self._ccbOwner.ziDisCountBg:setVisible(false)
		self._ccbOwner.chengDisCountBg:setVisible(false)
		self._ccbOwner.hongDisCountBg:setVisible(false)
		if tonumber(colorType) == 1 then
			-- 蓝
			self._ccbOwner.lanDisCountBg:setVisible(true)
		elseif tonumber(colorType) == 2 then
			-- 紫
			self._ccbOwner.ziDisCountBg:setVisible(true)
		elseif tonumber(colorType) == 3 then
			-- 橙
			self._ccbOwner.chengDisCountBg:setVisible(true)
		elseif tonumber(colorType) == 4 then
			-- 红
			self._ccbOwner.hongDisCountBg:setVisible(true)
		else
			-- 蓝
			self._ccbOwner.lanDisCountBg:setVisible(true)
		end
		if int >= 1 then
			self._ccbOwner.discountStr:setString(int.." 折")
		else
			self._ccbOwner.discountStr:setString(int.."折")
		end
		self._ccbOwner.node_sale:setVisible(true)
	else
		self._ccbOwner.node_sale:setVisible(false)
	end
end

function QUIWidgetStoreAwardsBox:setCurrencyIcon()
	local currencyInfo = remote.items:getWalletByType(self._shopInfo.currencyType)
   	local path = currencyInfo.alphaIcon
   	if self._icon ~= nil then 
   		self._icon:removeFromParent()
   		self._icon = nil
   	end

  	if path ~= nil then
  		self._ccbOwner.node_price_icon_1:removeAllChildren()
	    self._icon = CCSprite:create()
	    self._icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	    self._ccbOwner.node_price_icon_1:addChild(self._icon)
  	end
end

function QUIWidgetStoreAwardsBox:setConditionBar(awardsInfo)
	if self._awards.term == nil then return end

	local tipsStr = self._awards.describe or ""
	local canBuy = false
	local condition = 0
	local canBuy, condition, currency = remote.stores:checkAwardsCanBuy(self._awards)
	local fontColor = COLORS.e
	self._canSell = false
	if canBuy or self.isSell then
		self._canSell = true
		fontColor = COLORS.a
	end
	local tipsRichText = QRichText.new("", self._tipsMaxSizeWidth, {stringType = 1, defaultColor = fontColor, defaultSize = 22, autoCenter = true})
	tipsRichText:setString(tipsStr)
	-- local tipsWidth = tipsRichText:getCascadeBoundingBox().size.width
	local tipsHeight = tipsRichText:getCascadeBoundingBox().size.height
	tipsRichText:setScale(1)
	if tipsHeight > self._tipsMaxSizeHeight then
		tipsRichText:setScale( 1 - (tipsHeight - self._tipsMaxSizeHeight) / self._tipsMaxSizeHeight )
	end
	tipsRichText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_tips:addChild(tipsRichText)

	self._ccbOwner.red_tips:setVisible(false)
	if self._canSell and self.isSell == false then
		self._ccbOwner.red_tips:setVisible(true)
	end
end 

function QUIWidgetStoreAwardsBox:_setItemIsSell()
	self._ccbOwner.ly_empty:setVisible(true)
	self._ccbOwner.sp_empty:setVisible(true)
	self.isSell = true
	makeNodeFromNormalToGray(self._itmeBox)
	self._ccbOwner.red_tips:setVisible(false)
end

function QUIWidgetStoreAwardsBox:getItemState()
	return self.isSell
end

function QUIWidgetStoreAwardsBox:getItemInfo()
	return self._itemInfo
end

function QUIWidgetStoreAwardsBox:getSpPartition()
	return self._ccbOwner.sp_partition
end

function QUIWidgetStoreAwardsBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetStoreAwardsBox:_onTirggerClick()
	self:dispatchEvent({name = QUIWidgetStoreAwardsBox.EVENT_CLICK_AWARDS_BOX, awards = self._awards.shop_id, itemInfo = self._itemInfo, isSell = self.isSell, canSell = self._canSell})
end

return QUIWidgetStoreAwardsBox