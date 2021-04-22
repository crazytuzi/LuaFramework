--
-- Author: xurui
-- Date: 2016-03-23 20:32:40
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEnchantAwardsBox = class("QUIWidgetEnchantAwardsBox", QUIWidget)


local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QShop = import("...utils.QShop")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")

QUIWidgetEnchantAwardsBox.EVENT_CLICK = "SOTRE_EVENT_CLICK"

function QUIWidgetEnchantAwardsBox:ctor(options)
	local ccbFile = "ccb/Widget_shop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTirggerClick", callback = handler(self, self._onTirggerClick)},
		{ccbCallbackName = "onTirggerItemClick", callback = handler(self, self._onTirggerItemClick)}
	}
	QUIWidgetEnchantAwardsBox.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._nameMaxSize = self._ccbOwner.node_name_size:getContentSize().width
	self._tipsMaxSize = self._ccbOwner.node_tips_size:getContentSize().width

	if options ~= nil then
		self.position = options.position
		self.shopType = options.shopType
	end
end

function QUIWidgetEnchantAwardsBox:onEnter()
end 

function QUIWidgetEnchantAwardsBox:onExit()
	if self._shakeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._shakeScheduler)
		self._shakeScheduler = nil
	end
end

function QUIWidgetEnchantAwardsBox:resetAll()
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
	self._ccbOwner.node_price:setVisible(false)
	self._ccbOwner.node_price_1:setVisible(false)
	self._ccbOwner.node_price_2:setVisible(false)
	self._ccbOwner.sp_new:setVisible(false)

	self._ccbOwner.node_goods_name:removeAllChildren()
	self._ccbOwner.node_tips:removeAllChildren()

	if self._soulEffect ~= nil then
		self._soulEffect:disappear()
		self._soulEffect = nil
	end
	
	self._isDiscountSoul = false
	self.isSell = false
end

function QUIWidgetEnchantAwardsBox:setPostionType(pos, shopType)
	self.position = pos
	self.shopType = shopType
end

function QUIWidgetEnchantAwardsBox:setItmeBox(itemInfo)
	self:resetAll()

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemInfo.id)

	self._ccbOwner.sp_partition:setVisible(itemInfo.isPartition)

	if self._itmeBox == nil then
		self._itmeBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_itembox:addChild(self._itmeBox)
	end
	self._itmeBox:setGoodsInfo(itemInfo.id, "item", itemInfo.num)
	
	-- 设置货物名字、颜色、大小
	local fontColor = COLORS.w
	local shadowColor = COLORS.Y
	if itemConfig.colour ~= nil and remote.stores.itemQualityIndex[tonumber(itemConfig.colour)] ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[remote.stores.itemQualityIndex[tonumber(itemConfig.colour)]]
		shadowColor = getShadowColorByFontColor(fontColor)
	end
	local nameRichText = QRichText.new("", nil, {stringType = 1, defaultColor = fontColor, strokeColor = shadowColor, defaultSize = 22})
	nameRichText:setString(itemConfig.name or "")
	local nameWidth = nameRichText:getCascadeBoundingBox().size.width
	nameRichText:setScale(1)
	if nameWidth > self._nameMaxSize then
		nameRichText:setScale( 1 - (nameWidth - self._nameMaxSize) / self._nameMaxSize )
	end
	nameRichText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_goods_name:addChild(nameRichText)

    self._ccbOwner.tf_price_1:setString(itemInfo.score_cost)
	self._ccbOwner.node_price:setVisible(true)
	self._ccbOwner.node_price_1:setVisible(true)


	self._currencyInfo = remote.items:getWalletByType("enchanting_integral")
	self:setCurrencyIcon()


	self._itemInfo = {id = itemInfo.id, itemType = "item", moneyType = "enchantScore", count = itemInfo.num, cost = itemInfo.score_cost}
end

function QUIWidgetEnchantAwardsBox:setSThreeOff()
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
		-- if aptitudeInfo.lower == "s" then
		if aptitudeInfo and aptitudeInfo.soulPrice then
			-- 确定是s级的
			local count = self._itemInfo.count
			local price = aptitudeInfo.soulPrice
			if self._itemInfo.cost == count * price * 0.7 then
				self._ccbOwner.node_sale:setVisible(true)
				self._ccbOwner.lanDisCountBg:setVisible(true)
				self._ccbOwner.discountStr:setString(string.format("%s折", 7))
				self._isDiscountSoul = true
				self._ccbOwner.sp_recommend:setVisible(false)
				self._ccbOwner.sp_assist:setVisible(false)
				self._ccbOwner.sp_combination:setVisible(false)
				self._ccbOwner.node_name:setPositionX(0)
			end
		end
	end
end

function QUIWidgetEnchantAwardsBox:setSellState()
	if self._itemInfo.sellState == nil then return end
	if self._itemInfo.sale then-- == QShop.ITEM_SELL_SALE then
		self:hidAllDiscountLabel()
		if self._itemInfo.sale*10 <	 10 then
			self._ccbOwner.node_sale:setVisible(true)
			self._ccbOwner.sp_recommend:setVisible(false)
			self._ccbOwner.sp_assist:setVisible(false)
			self._ccbOwner.sp_combination:setVisible(false)
			self._ccbOwner.node_name:setPositionX(0)
			if self._itemInfo.sale*10 < 4 then
				self._ccbOwner.hongDisCountBg:setVisible(true)
			elseif self._itemInfo.sale*10 < 7 then
				self._ccbOwner.ziDisCountBg:setVisible(true)
			else
				self._ccbOwner.lanDisCountBg:setVisible(true)
			end
			self._ccbOwner.discountStr:setString(string.format("%s折", self._itemInfo.sale*10))
		end
	elseif self._itemInfo.sellState == QShop.ITEM_SELL_RECOMMEND then
		self._ccbOwner.node_sale:setVisible(false)
		self._ccbOwner.sp_recommend:setVisible(true)
		self._ccbOwner.sp_assist:setVisible(false)
		self._ccbOwner.sp_combination:setVisible(false)
		self._ccbOwner.node_name:setPositionX(0)
	end
end

function QUIWidgetEnchantAwardsBox:hidAllDiscountLabel()
	self._ccbOwner.chengDisCountBg:setVisible(false)
	self._ccbOwner.lanDisCountBg:setVisible(false)
	self._ccbOwner.ziDisCountBg:setVisible(false)
	self._ccbOwner.hongDisCountBg:setVisible(false)
end

function QUIWidgetEnchantAwardsBox:setCurrencyIcon()
  	local path = self._currencyInfo.alphaIcon
   	if self.icon ~= nil then
   		self.icon:removeFromParent()
   		self.icon = nil
   	end

  	if path ~= nil then
	    self.icon = CCSprite:create()
	    self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	    self._ccbOwner.node_price_icon_1:addChild(self.icon)
  	end
end

function QUIWidgetEnchantAwardsBox:_showHeroAssist()
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
	self._ccbOwner.sp_assist:setVisible(showAssist)
	self._ccbOwner.sp_combination:setVisible(not showAssist)

	if showAssist == false then
		self:_showHeroCombination(actorId)
	end
end

function QUIWidgetEnchantAwardsBox:setPieceNum()
	self._ccbOwner.node_tips:removeAllChildren()
	if self._itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB or self._itemConfig.type == nil then return end
	local tipsStr = ""
	if self._itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
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
		    local currentNum = remote.items:getItemsNumByID(self._itemInfo.id) or 0
			tipsStr = "拥有："..currentNum
		else
			local numWord = ""
			local currentNum = remote.items:getItemsNumByID(self._itemInfo.id)
		    local heroInfo = remote.herosUtil:getHeroByID(actorId)
		    local gradeLevel = 0
		    if heroInfo ~= nil then
		    	gradeLevel = heroInfo.grade+1 or 0
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
		end
	else
	    local currentNum = remote.items:getItemsNumByID(self._itemInfo.id) or 0
		tipsStr = "拥有："..currentNum
	end

	local tipsRichText = QRichText.new("", nil, {stringType = 1, defaultColor = COLORS.a, defaultSize = 20})
	tipsRichText:setString(tipsStr)
	local tipsWidth = tipsRichText:getCascadeBoundingBox().size.width
	tipsRichText:setScale(1)
	if tipsWidth > self._tipsMaxSize then
		tipsRichText:setScale( 1 - (tipsWidth - self._tipsMaxSize) / self._tipsMaxSize )
	end
	tipsRichText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_tips:addChild(tipsRichText)
end

function QUIWidgetEnchantAwardsBox:_showHeroCombination(actorId)
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
			self._isCombination = true
			break
		end
	end
	self._ccbOwner.sp_combination:setVisible(self._isCombination)
end

--设置物品已购买
function QUIWidgetEnchantAwardsBox:_setItemIsSell(noAnimation)
	if not noAnimation then
		self._ccbOwner.sp_empty:setVisible(false)
		self._saleEffect = QUIWidgetAnimationPlayer.new()
		local emptyParent = self._ccbOwner.sp_empty:getParent()
		if emptyParent then
			emptyParent:addChild(self._saleEffect)
			self._saleEffect:playAnimation("ccb/effects/chushou.ccbi", function()end, function()
				end, false)

			self._shakeScheduler = scheduler.performWithDelayGlobal(function()
					if self.setItemBoxShakeEffect then
						self:setItemBoxShakeEffect()
					end
				end, 1/6)
		end	
	else
		self._ccbOwner.sp_empty:setVisible(true)
	end

	self._isDiscountSoul = false
	self._itemInfo.count = 0

	makeNodeFromNormalToGray(self._itemBox)
	self.isSell = true
	if self._soulEffect ~= nil then
		self._soulEffect:disappear()
		self._soulEffect = nil
	end
end

--设置物品可购买
function QUIWidgetEnchantAwardsBox:_setItemCanSell()
	self._ccbOwner.sp_empty:setVisible(false)

	makeNodeFromGrayToNormal(self._itemBox)
	self.isSell = false
	if self._saleEffect ~= nil then
		self._saleEffect:disappear()
		self._saleEffect = nil
	end
end

function QUIWidgetEnchantAwardsBox:needItem()
	if self.isSell == false and self._itemInfo.count > 0 then
		self._itemBox:showGreenTips(true)
	end
end

function QUIWidgetEnchantAwardsBox:showSoulEffect()
	self._ccbOwner.soul_effect:removeAllChildren()
	self._ccbOwner.soul_effect:setVisible(true)

	self._soulEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.soul_effect:addChild(self._soulEffect)
	self._soulEffect:playAnimation("ccb/effects/widget_baoshi_shop_zguang.ccbi", function()end, function()end,false)
end

function QUIWidgetEnchantAwardsBox:setItemBoxShakeEffect()
	local time = 0.032
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(time, 0.96))
	ccArray:addObject(CCScaleTo:create(time, 1))
	self._ccbOwner.parent_node:runAction(CCSequence:create(ccArray))
end

function QUIWidgetEnchantAwardsBox:getContentSize()
	local contentSize = self._ccbOwner.node_size:getContentSize()
	return CCSize(contentSize.width, contentSize.height)
end

function QUIWidgetEnchantAwardsBox:getItmeBoxContentSize()
	local contentSize = self._ccbOwner.node_size:getContentSize()
	return CCSize(contentSize.width, contentSize.height)
end

function QUIWidgetEnchantAwardsBox:_onTirggerClick()
	self:dispatchEvent({name = QUIWidgetEnchantAwardsBox.EVENT_CLICK, itemInfo = self._itemInfo, position = self.position, isSell = self.isSell, isCombination = self._isCombination})
end

function QUIWidgetEnchantAwardsBox:_onTirggerItemClick()
	if not app.tip:itemTipByItemInfo( self._itemInfo , false) then
		self:_onTirggerClick()
		QPrintTable(self._itemInfo)
	end
end

function QUIWidgetEnchantAwardsBox:checkRefresh()
	if self._isDiscountSoul and self._itemInfo.count ~= 0 then
		return false
	end

	return true
end

return QUIWidgetEnchantAwardsBox