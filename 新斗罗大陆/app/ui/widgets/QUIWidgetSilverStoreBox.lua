--
-- Author: xurui
-- Date: 2016-07-27 19:47:17
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverStoreBox = class("QUIWidgetSilverStoreBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText")

QUIWidgetSilverStoreBox.SILVER_STORE_BOX_EVENT = "SILVER_STORE_BOX_EVENT"

function QUIWidgetSilverStoreBox:ctor(options)
	local ccbFile = "ccb/Widget_shop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTirggerClick", callback = handler(self, QUIWidgetSilverStoreBox._onTirggerClick)},
		{ccbCallbackName = "onTirggerItemClick", callback = handler(self, QUIWidgetSilverStoreBox._onTirggerItemClick)},
	}
	QUIWidgetSilverStoreBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._icon = {}
	self._itemIcon = {}

	self._nameMaxSize = self._ccbOwner.node_name_size:getContentSize().width
	self._tipsMaxSize = self._ccbOwner.node_tips_size:getContentSize().width
end

function QUIWidgetSilverStoreBox:onEnter()
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
end

function QUIWidgetSilverStoreBox:onExit()
  	self.prompt:removeItemEventListener()
end

function QUIWidgetSilverStoreBox:resetAll()
	self._ccbOwner.node_name:setPositionX(-27) -- 初始狀態（即沒有角標）劇中顯示

	self._ccbOwner.sp_partition:setVisible(false)
	self._ccbOwner.node_order:setVisible(false)
	self._ccbOwner.node_select:setVisible(false)
	self._ccbOwner.node_sale:setVisible(false)
	self._ccbOwner.sp_empty:setVisible(false)
	self._ccbOwner.sp_recommend:setVisible(false)
	self._ccbOwner.sp_assist:setVisible(false)
	self._ccbOwner.sp_combination:setVisible(false)
	self._ccbOwner.soul_effect:setVisible(false)
	self._ccbOwner.node_price:setVisible(true)
	self._ccbOwner.node_price_1:setVisible(false)
	self._ccbOwner.node_price_2:setVisible(false)
	self._ccbOwner.sp_new:setVisible(false)

	self._ccbOwner.node_goods_name:removeAllChildren()
	self._ccbOwner.node_tips:removeAllChildren()

	if self._soulEffect ~= nil then
		self._soulEffect:disappear()
		self._soulEffect = nil
	end
end

function QUIWidgetSilverStoreBox:setItmeBox(itemInfo)
	self:resetAll()
	-- QPrintTable(itemInfo)

	self._itemInfo = itemInfo
	
	self._index = self._itemInfo.index

	self._ccbOwner.sp_partition:setVisible(self._itemInfo.isPartition)
	self._itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemInfo.item_id)
	local name = ""
	if self._itemInfo.item_type ~= "item" then
		self._itemConfig = remote.items:getWalletByType(self._itemInfo.item_type)
		name = self._itemConfig.nativeName
	else
		name = self._itemConfig.name
	end

	self._ccbOwner.sp_new:setVisible(self._itemInfo.is_new == 1)

	-- set item box
	if self._itemBox ~= nil then 
		self._itemBox:removeFromParent()
		self._itemBox = nil
	end
	self._ccbOwner.node_itembox:removeAllChildren()
	self._itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.node_itembox:addChild(self._itemBox)
	self._itemBox:setGoodsInfo(self._itemInfo.item_id, self._itemInfo.item_type, self._itemInfo.item_number)

	-- 设置货物名字、颜色、大小
	local fontColor = COLORS.w
	local shadowColor = COLORS.Y
	if self._itemConfig.colour ~= nil and remote.stores.itemQualityIndex[tonumber(self._itemConfig.colour)] ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[remote.stores.itemQualityIndex[tonumber(self._itemConfig.colour)]]
		shadowColor = getShadowColorByFontColor(fontColor)
	end
	local nameRichText = QRichText.new("", nil, {stringType = 1, defaultColor = fontColor, strokeColor = shadowColor, defaultSize = 22})
	nameRichText:setString(name or "")
	local nameWidth = nameRichText:getCascadeBoundingBox().size.width
	nameRichText:setScale(1)
	if nameWidth > self._nameMaxSize then
		nameRichText:setScale( 1 - (nameWidth - self._nameMaxSize) / self._nameMaxSize )
	end
	nameRichText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_goods_name:addChild(nameRichText)

	-- set exchange info 
	local num = 0
	for i = 1, 2 do
		self:clearCurrncyInfo(i)
		if self._itemInfo["resource_"..i] ~= nil and self._itemInfo["resource_"..i] ~= "item" then
			self:setCurrencyInfo(i)
			num = num + 1
		elseif self._itemInfo["resource_item_"..i] ~= nil then
			self:setItemInfo(i)
			num = num + 1
		end
	end
	self._ccbOwner.node_price_2:setVisible(not (num == 1))


	local fontColor = COLORS.a
	local tipsStr = ""
	local buyInfo = remote.exchangeShop:getShopBuyInfo(self._itemInfo.shop_id)
	local buyNum = buyInfo[tostring(self._itemInfo.grid_id)] or 0
	local lostNum = (self._itemInfo.exchange_number or 0) - buyNum
	print("[QUIWidgetSilverStoreBox] lostNum :", lostNum, self._itemInfo.exchange_number_week, self._itemInfo.exchange_number, buyNum, self._itemInfo.grid_id, self._itemInfo.index)
	if self._itemInfo.exchange_number ~= nil then
		self.canSell = remote.stores:checkShopCanBuy(self._itemInfo)
		if self.canSell then
			if lostNum > 0 then
				if self._itemInfo.can_not_refresh == 1 then
					if tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.musicShop) then
						tipsStr = "本期兑换:"..lostNum.."/"..self._itemInfo.exchange_number
					else
						tipsStr = "永久可兑换:"..lostNum.."/"..self._itemInfo.exchange_number
					end
				else
					if tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.crystalShop) or tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.godarmShop) or 
						tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.silvesShop) then
						tipsStr = "本周可兑换:"..lostNum.."/"..self._itemInfo.exchange_number
					elseif tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.mockbattleShop) then
						tipsStr = "赛季可兑换:"..lostNum.."/"..self._itemInfo.exchange_number
					elseif tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.monthSignInShop) then
						tipsStr = "本月可兑换:"..lostNum.."/"..self._itemInfo.exchange_number
					else
						tipsStr = "今日可兑换:"..lostNum.."/"..self._itemInfo.exchange_number
					end
				end
			else
				if self._itemInfo.can_not_refresh == 1 then
					if tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.musicShop) then
						tipsStr = "本期已达上限"
					else
						tipsStr = "永久兑换上限"
					end
				else
					if tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.crystalShop) or tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.godarmShop) or 
						tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.silvesShop) then
						tipsStr = "本周已达上限"
					elseif tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.mockbattleShop) then
						tipsStr = "本赛季已达上限"
					elseif tonumber(self._itemInfo.shop_id) == tonumber(SHOP_ID.monthSignInShop) then
						tipsStr = "本月已达上限"						
					else					
						tipsStr = "今日已达上限"
					end
				end
				fontColor = COLORS.e
			end
		else
			tipsStr = self._itemInfo.condition_des
			fontColor = COLORS.e
		end
	elseif self._itemInfo.exchange_number_week ~= nil then
		local exchangeNum = (self._itemInfo.exchange_number_week or 0) - buyNum
		if exchangeNum > 0 then
			tipsStr = "本周可兑换:"..exchangeNum.."/"..self._itemInfo.exchange_number_week
		else
			tipsStr = "本周已达上限"
			fontColor = COLORS.e
		end
	else
		local haveNum = 1
		if self._itemInfo.item_type == "item" then
			haveNum = remote.items:getItemsNumByID(self._itemInfo.item_id)
		else
			local moneyInfo = remote.items:getWalletByType(self._itemInfo.item_type)
			haveNum = remote.user[moneyInfo.name]
		end
		tipsStr = "拥有："..haveNum
	end

	local tipsRichText = QRichText.new("", nil, {stringType = 1, defaultColor = fontColor, defaultSize = 20})
	tipsRichText:setString(tipsStr)
	local tipsWidth = tipsRichText:getCascadeBoundingBox().size.width
	tipsRichText:setScale(1)
	if tipsWidth > self._tipsMaxSize then
		tipsRichText:setScale( 1 - (tipsWidth - self._tipsMaxSize) / self._tipsMaxSize )
	end
	tipsRichText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_tips:addChild(tipsRichText)

	self:setSellState()
end

function QUIWidgetSilverStoreBox:hidAllDiscountLabel()
	self._ccbOwner.chengDisCountBg:setVisible(false)
	self._ccbOwner.lanDisCountBg:setVisible(false)
	self._ccbOwner.ziDisCountBg:setVisible(false)
	self._ccbOwner.hongDisCountBg:setVisible(false)
end

function QUIWidgetSilverStoreBox:setSellState()
	local sale = self._itemInfo.exchange_discount
	if sale then
		self:hidAllDiscountLabel()
		if sale*10 < 10 then
			self._ccbOwner.node_sale:setVisible(true)
			self._ccbOwner.sp_recommend:setVisible(false)
			self._ccbOwner.sp_assist:setVisible(false)
			self._ccbOwner.sp_combination:setVisible(false)
			self._ccbOwner.node_name:setPositionX(0)
			if sale*10 < 4 then
				self._ccbOwner.hongDisCountBg:setVisible(true)
			elseif sale*10 < 7 then
				self._ccbOwner.ziDisCountBg:setVisible(true)
			else
				self._ccbOwner.lanDisCountBg:setVisible(true)
			end
			self._ccbOwner.discountStr:setString(string.format("%s折", sale*10))
		end
	end
end

function QUIWidgetSilverStoreBox:setCurrencyInfo(index)
  	local path = remote.items:getWalletByType(self._itemInfo["resource_"..index]).alphaIcon
  	
  	if path ~= nil then
  		self._ccbOwner["node_price_icon_"..index]:removeAllChildren()
	    self._icon[index] = CCSprite:create()
	    self._icon[index]:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	    self._ccbOwner["node_price_icon_"..index]:addChild(self._icon[index])
  	end

  	self._ccbOwner["tf_price_"..index]:setString(self._itemInfo["resource_number_"..index] or 0)
  	self._ccbOwner["node_price_"..index]:setVisible(true)
end

function QUIWidgetSilverStoreBox:setItemInfo(index)
	self._ccbOwner["node_price_icon_"..index]:removeAllChildren()
	local path = QStaticDatabase:sharedDatabase():getItemByID(tonumber(self._itemInfo["resource_item_"..index])).icon_1
	if path then
	    self._itemIcon[index] = CCSprite:create()
	    self._itemIcon[index]:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	    self._ccbOwner["node_price_icon_"..index]:addChild(self._itemIcon[index])
	  	self._ccbOwner["tf_price_"..index]:setString(self._itemInfo["resource_number_"..index] or 0)
	  	self._ccbOwner["node_price_"..index]:setVisible(true)
	end
end

function QUIWidgetSilverStoreBox:clearCurrncyInfo(index)
	if self._icon[index] ~= nil then
  		self._icon[index]:removeFromParent()
  		self._icon[index] = nil
	end
	if self._itemIcon[index] ~= nil then
  		self._itemIcon[index]:removeFromParent()
  		self._itemIcon[index] = nil
	end
  	self._ccbOwner["tf_price_"..index]:setString("")
end

function QUIWidgetSilverStoreBox:getItemInfo()
	return self._itemInfo
end 

function QUIWidgetSilverStoreBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilverStoreBox:_onTirggerClick()
	self:dispatchEvent({name = QUIWidgetSilverStoreBox.SILVER_STORE_BOX_EVENT, index = self._index,itemInfo = self._itemInfo, canSell = self.canSell, shopId = self._itemInfo.shop_id})
end

function QUIWidgetSilverStoreBox:_onTirggerItemClick()
	if not app.tip:itemTipByItemInfo( self._itemInfo , false) then
		self:_onTirggerClick()
		QPrintTable(self._itemInfo)
	end
end

return QUIWidgetSilverStoreBox