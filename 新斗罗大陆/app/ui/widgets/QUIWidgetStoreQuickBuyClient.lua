-- @Author: xurui
-- @Date:   2017-02-24 17:49:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-22 19:59:52
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStoreQuickBuyClient = class("QUIWidgetStoreQuickBuyClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")

QUIWidgetStoreQuickBuyClient.EVENT_CLICK = "SOTRE_EVENT_CLICK"

function QUIWidgetStoreQuickBuyClient:ctor(options)
	local ccbFile = "ccb/Widget_shop.ccbi"
	local callBack = {
		{ccbCallbackName = "onTirggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTirggerItemClick", callback = handler(self, self._onTirggerItemClick)}
	}
	QUIWidgetStoreQuickBuyClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._nameMaxSize = self._ccbOwner.node_name_size:getContentSize().width
	self._tipsMaxSize = self._ccbOwner.node_tips_size:getContentSize().width
end

function QUIWidgetStoreQuickBuyClient:resetAll()
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
	self.canSell = true
end

function QUIWidgetStoreQuickBuyClient:setInfo(param)
	self:resetAll()
	self._ccbOwner.sp_partition:setVisible(param.isPartition)
	self._shopId = param.shopId
	local chooseItem = param.chooseItem
	local itemInfo = param.info
	local id = itemInfo.id
	if id == nil or id == ""  then
		id = itemInfo.itemType
	end	
	if param.typeNum == 1 then
		local state = false
		if chooseItem[id] then
			if ( chooseItem[id][1] and chooseItem[id][1].moneyType == itemInfo.moneyType and tonumber(chooseItem[id][1].moneyNum) == tonumber(itemInfo.moneyNum)) or 
				( chooseItem[id][2] and chooseItem[id][2].moneyType == itemInfo.moneyType and tonumber(chooseItem[id][2].moneyNum) == tonumber(itemInfo.moneyNum)) or 
				( chooseItem[id][3] and chooseItem[id][3].moneyType == itemInfo.moneyType and tonumber(chooseItem[id][3].moneyNum) == tonumber(itemInfo.moneyNum)) or
				( chooseItem[id][4] and chooseItem[id][4].moneyType == itemInfo.moneyType and tonumber(chooseItem[id][4].moneyNum) == tonumber(itemInfo.moneyNum)) then
				state = true
			end
		end
		self._ccbOwner.node_select:setVisible(true)
		self:setChooseState(state)
		self:setItmeBox(itemInfo)
	else
		local selectNum = self:getSelectNum(chooseItem, itemInfo.grid_id)
		self:setSelectNum(selectNum)
		self:setItmeBoxLimit(itemInfo)
	end
end

function QUIWidgetStoreQuickBuyClient:getSelectNum(chooseItem, gridId)
	for i, v in pairs(chooseItem) do
    	if v.gridId == gridId then
    		return i
    	end
    end
    return 0
end

function QUIWidgetStoreQuickBuyClient:setItmeBox(itemInfo)
	if self._itemBox ~= nil then
		self._itemBox:removeFromParent()
		self._itemBox = nil
	end
	self._itemInfo = itemInfo
	local itemConfig = nil
	local name = ""
	local itemType = self._itemInfo.itemType
	if itemType == "soul_gem" then 
		itemType = "item"
	end
	if itemType == "item" then
		itemConfig = db:getItemByID(self._itemInfo.id)
		if itemConfig == nil then return end
		name = itemConfig.name
	else
		itemConfig = remote.items:getWalletByType(itemType)
		name = itemConfig.nativeName
	end

	local itemMoney = self._itemInfo.moneyNum
	local itemCount = 1
	if itemConfig.type == nil or itemConfig.type ~= ITEM_CONFIG_TYPE.SOUL then
		itemMoney = itemMoney*10
		itemCount = 10
		if itemConfig.name == "trainMoney" and remote.user.level >= 100 then
			itemMoney = itemMoney*10
			itemCount = 100
		end
	end
	self._itemConfig = itemConfig

	if self._itemBox == nil then
		self._ccbOwner.node_itembox:removeAllChildren()
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_itembox:addChild(self._itemBox)
		self._itemBox:setPromptIsOpen(true)
	end
	self._itemBox:setGoodsInfo(self._itemInfo.id, itemType, itemCount)

	-- 设置货物名字、颜色、大小
	local fontColor = COLORS.w
	local shadowColor = COLORS.Y
	if itemConfig.colour ~= nil and remote.stores.itemQualityIndex[tonumber(itemConfig.colour)] ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[remote.stores.itemQualityIndex[tonumber(itemConfig.colour)]]
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


	self._currencyInfo = remote.items:getWalletByType(self._itemInfo.moneyType)
	if self._currencyInfo == nil then return end 

    self._ccbOwner.tf_price_1:setString(math.ceil(itemMoney))
    self._ccbOwner.node_price_1:setVisible(true)

	self:setSellState()
	self:setSThreeOff()
	self:setCurrencyIcon()
	self:_showHeroAssist()
	self:setPieceNum()

	local isNeed = remote.stores:checkItemIsNeed(self._itemInfo.id, self._itemInfo.count)
	if isNeed then
    	self:needItem()  
    end
end

function QUIWidgetStoreQuickBuyClient:setItmeBoxLimit(itemInfo)
	self._itemInfo = itemInfo
	self._itemId = itemInfo.item_id
	self._itemNum = itemInfo.item_number
	self._itemConfig = db:getItemByID(self._itemId)

	local name = ""
	if self._itemInfo.item_type ~= "item" then
		self._itemConfig = remote.items:getWalletByType(self._itemInfo.item_type)
		name = self._itemConfig.nativeName
	else
		name = self._itemConfig.name
	end

	-- set item box
	if self._itemBox ~= nil then 
		self._itemBox:removeFromParent()
		self._itemBox = nil
	end
	self._ccbOwner.node_itembox:removeAllChildren()
	self._itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.node_itembox:addChild(self._itemBox)
	self._itemBox:setGoodsInfo(self._itemId, self._itemInfo.item_type, self._itemNum)
	if self._itemConfig.type ~= ITEM_CONFIG_TYPE.GEMSTONE_PIECE and self._itemConfig.type ~= ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
		self._itemBox:setPromptIsOpen(true)
	else
		self._itemBox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._clickItemBox))
	end

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


	local fontColor = COLORS.a
	local tipsStr = ""
	local buyInfo = remote.exchangeShop:getShopBuyInfo(self._shopId)
	local buyNum = buyInfo[tostring(self._itemInfo.grid_id)] or 0
	local lostNum = (self._itemInfo.exchange_number or 0) - buyNum
	if self._itemInfo.exchange_number ~= nil then
		self.canSell = remote.stores:checkShopCanBuy(self._itemInfo)
		if self.canSell then
			if lostNum > 0 then
				if self._itemInfo.can_not_refresh == 1 then
					tipsStr = "永久可兑换:"..lostNum.."/"..self._itemInfo.exchange_number
				else
					tipsStr = "今日可兑换:"..lostNum.."/"..self._itemInfo.exchange_number
				end
			else
				if self._itemInfo.can_not_refresh == 1 then
					tipsStr = "永久兑换上限"
				else
					tipsStr = "今日已达上限"
				end
				fontColor = COLORS.e
			end
		else
			tipsStr = self._itemInfo.condition_des
			fontColor = COLORS.e
		end
	else
		local haveNum = 1
		if self._itemInfo.item_type == "item" then
			haveNum = remote.items:getItemsNumByID(self._itemId)
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

	self._currencyInfo = remote.items:getWalletByType(self._itemInfo.resource_1)
	if self._currencyInfo == nil then return end 
    self._ccbOwner.tf_price_1:setString(self._itemInfo.resource_number_1)
    self._ccbOwner.node_price_1:setVisible(true)
    
	self:setSellState()
	self:setCurrencyIcon()
end

function QUIWidgetStoreQuickBuyClient:setChooseState(state)
	if state == nil then state = false end

	self.chooseState = state
	self._ccbOwner.sp_select_on:setVisible(state)
end

function QUIWidgetStoreQuickBuyClient:setSelectNum(num)
	self.chooseState = num > 0
	self._ccbOwner.node_order:setVisible(self.chooseState)
	self._ccbOwner.tf_order:setString(num)
	if self.chooseState then
		self._ccbOwner.sp_new:setVisible(false)
	end
end

function QUIWidgetStoreQuickBuyClient:getChooseState()
	return self.chooseState
end

function QUIWidgetStoreQuickBuyClient:setSThreeOff()
	if not self._itemConfig and self._itemConfig.moneyType ~= "TOKEN" then return end
	-- 确定是钻石购买的物品

	local id = self._itemInfo.id
	local itemConfig = QStaticDatabase.sharedDatabase():getItemByID( id )
	if not itemConfig then return end
	-- 确定是item
	if itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
		-- 确定是魂力精魄
		local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId( id )
		local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC( actorId )
		if aptitudeInfo.lower == "s" then
			-- 确定是s级的
			local count = self._itemInfo.count
			local price = 50
			if self._itemInfo.cost == count * price * 0.7 then
				self._ccbOwner.node_sale:setVisible(true)
				self._ccbOwner.sp_recommend:setVisible(false)
				self._ccbOwner.sp_assist:setVisible(false)
				self._ccbOwner.sp_combination:setVisible(false)
				self._ccbOwner.lanDisCountBg:setVisible(true)
				self._ccbOwner.discountStr:setString(string.format("%s折", 7))
				self._ccbOwner.node_name:setPositionX(0)
			end
		end
	end
end

function QUIWidgetStoreQuickBuyClient:setSellState()
	self:hidAllDiscountLabel()
	local sale = (self._itemInfo.sale or self._itemInfo.exchange_discount or 1)*10
	if sale < 10 then
		self._ccbOwner.node_sale:setVisible(true)
		self._ccbOwner.sp_recommend:setVisible(false)
		self._ccbOwner.sp_assist:setVisible(false)
		self._ccbOwner.sp_combination:setVisible(false)
		self._ccbOwner.node_name:setPositionX(0)
		if sale < 4 then
			self._ccbOwner.hongDisCountBg:setVisible(true)
		elseif sale < 7 then
			self._ccbOwner.ziDisCountBg:setVisible(true)
		else
			self._ccbOwner.lanDisCountBg:setVisible(true)
		end
		self._ccbOwner.discountStr:setString(string.format("%s折", sale))
	end
end

function QUIWidgetStoreQuickBuyClient:hidAllDiscountLabel()
	self._ccbOwner.chengDisCountBg:setVisible(false)
	self._ccbOwner.lanDisCountBg:setVisible(false)
	self._ccbOwner.ziDisCountBg:setVisible(false)
	self._ccbOwner.hongDisCountBg:setVisible(false)
end

function QUIWidgetStoreQuickBuyClient:setCurrencyIcon()
  	local path = self._currencyInfo.alphaIcon
   	if self.icon ~= nil then
   		self.icon:removeFromParent()
   		self.icon = nil
   	end

  	if path ~= nil then
  		self._ccbOwner.node_price_icon_1:removeAllChildren()
	    self.icon = CCSprite:create()
	    self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	    self._ccbOwner.node_price_icon_1:addChild(self.icon)
  	end
end

function QUIWidgetStoreQuickBuyClient:_showHeroAssist()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemInfo.id)
	if actorId == nil then return end
	if remote.herosUtil:checkHeroHavePast(actorId) then return end
	local heroInfos, count = remote.herosUtil:getMaxForceHeros()
	local checkActorId = function(actorId)
		for i = 1, count do
			if heroInfos[i] and heroInfos[i].id == actorId then
				return true
			end
		end
		return false
	end

	local showAssist = false
	local assistInfos = QStaticDatabase:sharedDatabase():getAllAssistSkillByActorId(actorId)
	for i = 1, #assistInfos do
		if assistInfos[i].hero ~= actorId and checkActorId(assistInfos[i].hero) then
			showAssist = true
			break
		end
	end
	if showAssist then
		self._ccbOwner.sp_assist:setVisible(true)
		self._ccbOwner.sp_recommend:setVisible(false)
		self._ccbOwner.node_name:setPositionX(0)
	else
		self:_showHeroCombination(actorId)
	end
end

function QUIWidgetStoreQuickBuyClient:setPieceNum()
    if self._itemConfig.type ~= ITEM_CONFIG_TYPE.SOUL then return end

	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId( self._itemInfo.id )
	if actorId == nil then return end

	-- 检查魂师品质
	local character = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

	-- 检查是否是TOPN
	local heros, count = remote.herosUtil:getMaxForceHeros()
	local isHave = false
	for i = 1, count do
		if heros[i] and heros[i].id == actorId then
			isHave = true
			break
		end
	end
	if isHave == false and character.aptitude < 20 then 
		return
	end

	local fontColor = COLORS.a
	local tipsStr = ""
	local numWord = ""
	local currentNum = remote.items:getItemsNumByID(self._itemInfo.id)
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    local gradeLevel = 0
    if heroInfo ~= nil then
    	gradeLevel = heroInfo.grade + 1 or 0
    end
    local info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(actorId, gradeLevel) or {}
    local needNum = info.soul_gem_count or 0
    local currentNum = remote.items:getItemsNumByID(self._itemInfo.id) or 0
    if needNum > 0 then
        numWord = currentNum.."/"..needNum
    else
        numWord = currentNum
    end
    tipsStr = "拥有："..numWord
    local tipsRichText = QRichText.new("", nil, {stringType = 1, defaultColor = fontColor, defaultSize = 20})
	tipsRichText:setString(tipsStr)
	local tipsWidth = tipsRichText:getCascadeBoundingBox().size.width
	tipsRichText:setScale(1)
	if tipsWidth > self._tipsMaxSize then
		tipsRichText:setScale( 1 - (tipsWidth - self._tipsMaxSize) / self._tipsMaxSize )
	end
	tipsRichText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_tips:addChild(tipsRichText)
end

function QUIWidgetStoreQuickBuyClient:_showHeroCombination(actorId)
	if actorId == nil then return end

	if remote.herosUtil:checkHeroHavePast(actorId) then return end

	local heroInfos, count = remote.herosUtil:getMaxForceHeros()
	local checkActorId = function(actorId)
		for i = 1, count do
			if heroInfos[i] and heroInfos[i].id == actorId then
				return true
			end
		end
		return false
	end

    local combinationInfos = QStaticDatabase:sharedDatabase():getCombinationInfoByactorId(actorId)
	for i = 1, #combinationInfos do
		if combinationInfos[i].hero_id ~= actorId and checkActorId(combinationInfos[i].hero_id) then
		    self._ccbOwner.sp_combination:setVisible(true)
		    self._ccbOwner.sp_recommend:setVisible(false)
		    self._ccbOwner.node_name:setPositionX(0)
			break
		end
	end
end

function QUIWidgetStoreQuickBuyClient:needItem()
	if self._itemInfo.count > 0 then
		self._itemBox:showGreenTips(true)
	end
end

function QUIWidgetStoreQuickBuyClient:showSoulEffect()
	self._ccbOwner.soul_effect:removeAllChildren()
	self._ccbOwner.soul_effect:setVisible(true)

	self._soulEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.soul_effect:addChild(self._soulEffect)
	self._soulEffect:playAnimation("ccb/effects/widget_baoshi_shop_zguang.ccbi", function()end, function()end,false)
end

function QUIWidgetStoreQuickBuyClient:setItemBoxShakeEffect()
	local time = 0.032
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(time, 0.96))
	ccArray:addObject(CCScaleTo:create(time, 1))
	self._ccbOwner.parent_node:runAction(CCSequence:create(ccArray))
end

function QUIWidgetStoreQuickBuyClient:getContentSize()
	local contentSize = self._ccbOwner.node_size:getContentSize()
	return CCSize(contentSize.width, contentSize.height)
end

function QUIWidgetStoreQuickBuyClient:getItemInfo()
	return self._itemInfo
end

function QUIWidgetStoreQuickBuyClient:_onTriggerClick()
	if self.canSell then
		self:dispatchEvent({name = QUIWidgetStoreQuickBuyClient.EVENT_CLICK, itemInfo = self._itemInfo, itemBox = self})
	else
		app.tip:floatTip("不满足兑换条件")
	end
end

function QUIWidgetStoreQuickBuyClient:_onTirggerItemClick()

	if not app.tip:itemTipByItemInfo( self._itemInfo , false) then
		self:_onTriggerClick()
		QPrintTable(self._itemInfo)
	end
end

return QUIWidgetStoreQuickBuyClient